function res = iif(x, y, z)
% IIF  Ternary operator for arrays
%
%   RES = IIF(X, Y, Z) construct an array RES of the same size as X, Y and Z.
%     RES contains the values of Y where X entries are true, and the values of
%     Z otherwise.
%
%   License: see LICENSE file
%
%   Authors: Charles Deledalle and Jérôme Gilles (2019)


    if length(x(:)) > 1
        res = y .* ones(size(x));
        res(~x) = z(~x);
    else
        if x
            res = y;
        else
            res = z;
        end
    end
