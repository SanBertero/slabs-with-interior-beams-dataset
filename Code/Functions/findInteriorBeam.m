function [hv,bv] = findInteriorBeam(hl,L,alpha)
    % Slab Inertia
    Is = L*hl^3/12;

    % Beam Thickness as a function of height
    bb = @(hb) max(hb/4,5);

    % Additional Flange as a function of height
    bf = @(hb) 2*min(4*hl,max(hb-hl,0));

    % Beam centroid as a function of height
    Yg = @(hb) (bb(hb).*hb.^2/2 + bf(hb)*hl^2/2)./(bb(hb).*hb+bf(hb)*hl);

    % Beam Inertia as a function of height
    Ib = @(hb) bb(hb).*hb.^3/12+bf(hb)*hl^3/12+bb(hb).*hb.*(Yg(hb)-hb/2).^2+...
        bf(hb).*hl.*(Yg(hb)-hl/2).^2;

    % Find Height
    fun = @(hb) Ib(hb)/Is - alpha;
    hv = fzero(fun,2*hl);

    bv = bb(hv);

end