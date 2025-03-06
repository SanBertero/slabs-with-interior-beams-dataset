function [hvx,bvx,hvy,bvy,alphax,alphay] = findCentralBeams(hl,Lx,Ly,alpha)
    % Slab Inertia
    Isx = Ly*hl^3/12;
    Isy = Lx*hl^3/12;

    % Beam Height as a function of Span
    hbx = @(rho) max(Lx/rho,0);
    hby = @(rho) max(Ly/rho,0);

    % Beam Thickness as a function of height
    bbx = @(rho) max(hbx(rho)/4,5);
    bby = @(rho) max(hby(rho)/4,5);

    % Additional Flange as a function of height
    bfx = @(rho) 2*min(4*hl,max(hbx(rho)-hl,0));
    bfy = @(rho) 2*min(4*hl,max(hby(rho)-hl,0));

    % Beam centroid as a function of height
    Ygx = @(rho) (bbx(rho).*hbx(rho).^2/2 + bfx(rho)*hl^2/2)./(bbx(rho).*hbx(rho)+bfx(rho)*hl);
    Ygy = @(rho) (bby(rho).*hby(rho).^2/2 + bfy(rho)*hl^2/2)./(bby(rho).*hby(rho)+bfy(rho)*hl);

    % Beam Inertia as a function of height
    Ibx = @(rho) bbx(rho).*hbx(rho).^3/12+bfx(rho)*hl^3/12+bbx(rho).*hbx(rho).*(Ygx(rho)-hbx(rho)/2).^2+...
        bfx(rho).*hl.*(Ygx(rho)-hl/2).^2;
    Iby = @(rho) bby(rho).*hby(rho).^3/12+bfy(rho)*hl^3/12+bby(rho).*hby(rho).*(Ygy(rho)-hby(rho)/2).^2+...
        bfy(rho).*hl.*(Ygy(rho)-hl/2).^2;

    % Calculate alpha
    Alpha_x = @(rho) Ibx(rho)/Isx;
    Alpha_y = @(rho) Iby(rho)/Isy;

    % Find Height
    fun = @(rho) 0.5*(Alpha_x(rho)+Alpha_y(rho)) - alpha;
    sol = fzero(fun,10);

    hvx = hbx(sol);
    hvy = hby(sol);
    bvx = bbx(sol);
    bvy = bby(sol);
    alphax = Alpha_x(sol);
    alphay = Alpha_y(sol);
end