function [l, dl, dsurr] = llba2epxbq_rounds_weeks_epsilon_win(x, D, mu, nui, doprior, options)
    dodiff = nargout == 2;
    np = length(x);
    beta = exp(x(1)); % sensitivity to reward and loss (combined)
    alfa = 1./(1+exp(-x(2))); % learning rate
    epsilon = [0, exp(x(4))]; % initialize only epsilon2
    g = 1/(1+exp(-x(5))); % irreducible noise
    b = x(6); % constant bias
    q0 = x(7); % initial Q-value (single q0)

    [l, dl] = logGaussianPrior(x, mu, nui, doprior);

    % Extract week information from D
    week = D.week;
    unique_weeks = unique(week);

    for w = 1:length(unique_weeks)
        week_mask = week == unique_weeks(w);

        % Update epsilon1 for the current week
        epsilon(1) = exp(x(3) + x(8)*(w-1));

        % Extract data for the current week
        a_week = D.a(week_mask);
        r_week = D.r(week_mask);
        s_week = D.s(week_mask);
        sess_week = D.session(week_mask);
        c_week = D.congruent(week_mask);

        % Get unique sessions within the current week
        sess = sess_week;
        unique_sess = unique(sess);

        for j = 1:length(unique_sess)
            sess_mask = sess == unique_sess(j);
            % Reset Q-values and other variables at the beginning of each week
            V = zeros(1, 4);
            Q = zeros(2, 4);
            Q(1, :) = q0;  % Initialize Q-values with q0
            dQdb = zeros(2, 4);
            dQde = zeros(2, 4);
            dVdb = zeros(4,4);
            dVde = zeros(4,1);
            dQdq = zeros(2, 4);
            dQdq(1, :) = 1;

            % Extract data for the current session within the week
            a = a_week(sess_mask);
            r = r_week(sess_mask);
            s = s_week(sess_mask);
            c = c_week(sess_mask);

            if options.generatesurrogatedata == 1
                a = zeros(size(a));
                dodiff = 0;
            end

            for t = 1:length(a)
                rho = sum(s(t)==[1 3]);
                q = Q(:,s(t));
                q(1) = q(1) + epsilon(2-rho) * V(s(t)) + b; % add Pavlovian effect
                l0 = q - max(q);
                la = l0 - log(sum(exp(l0)));
                p0 = exp(la);
                pg = g*p0 + (1-g)/2;

                if options.generatesurrogatedata == 1
                    [a(t), r(t)] = generatera_gng(pg', s(t), c(t));
                end

                l = l + log(pg(a(t)));
                er = beta * r(t);

                if dodiff
                    tmp = (dQdb(:,s(t)) + [epsilon(2-rho) * dVdb(s(t)); 0]);
                    dl(1) = dl(1) + g * (p0(a(t)) * (tmp(a(t)) - p0' * tmp)) / pg(a(t));
                    dQdb(a(t),s(t)) = (1-alfa) * dQdb(a(t),s(t)) + alfa * er;
                    dVdb(s(t)) = (1-alfa) * dVdb(s(t)) + alfa * er;

                    tmp = (dQde(:,s(t)) + [epsilon(2-rho)*dVde(s(t));0]);
		            dl(2) = dl(2) + g*(p0(a(t)) * (tmp(a(t)) - p0'*tmp)) / pg(a(t));
		            dQde(a(t),s(t)) = (1-alfa)*dQde(a(t),s(t)) + (er-Q(a(t),s(t)))*alfa*(1-alfa);
		            dVde(     s(t)) = (1-alfa)*dVde(     s(t)) + (er-V(     s(t)))*alfa*(1-alfa);

                    dl(4-rho) = dl(4-rho) + g*(p0(a(t))*epsilon(2-rho)*V(s(t)) * ((a(t)==1)-p0(1))) / pg(a(t));

                    dl(5) = dl(5) + g * (1-g) * (p0(a(t))-1/2) / pg(a(t));

                    tmp = [1; 0];
                    dl(6) = dl(6) + g * (p0(a(t)) * (tmp(a(t)) - p0' * tmp)) / pg(a(t));

                    dl(7) = dl(7) + g * (p0(a(t)) * (dQdq(a(t),s(t)) - p0' * dQdq(:,s(t)))) / pg(a(t));
                    dQdq(a(t),s(t)) = (1-alfa) * dQdq(a(t),s(t));

                    % Gradient for the week-specific epsilon1 adjustment (x(8))
                    if rho == 1
                       dl(8) = dl(8) + g * epsilon(1) * (p0(a(t)) * V(s(t)) * ((a(t) == 1) - p0(1))) / pg(a(t)) * (w - 1);
                    end
                 end

                Q(a(t),s(t)) = Q(a(t),s(t)) + alfa * (er - Q(a(t),s(t)));
                V(s(t)) = V(s(t)) + alfa * (er - V(s(t)));
            end
            if options.generatesurrogatedata == 1
                % Map indices back to original D indices
                full_mask = find(week_mask);
                sess_full_mask = full_mask(sess_mask);
                dsurr.a(sess_full_mask) = a;
                dsurr.r(sess_full_mask) = r;
                dsurr.s(sess_full_mask) = s;
                dsurr.j(sess_full_mask) = j;
                dsurr.session(sess_full_mask) = j;
                dsurr.week(sess_full_mask) = unique_weeks(w); % Save week information
            end
        end
    end

    l = -l;
    dl = -dl;
end