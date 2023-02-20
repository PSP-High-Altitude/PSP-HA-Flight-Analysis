function BN = eulerANGLEStoDCM(sequence,angles)
%% Angles in radians
rotMat = zeros(3,3,3);

    for i = 1:3
        theta = angles(i);
        switch sequence(i)
            case 1
                rotMat(:,:,i) = [1,0,0;
                                 0,cos(theta),sin(theta);
                                 0,-sin(theta),cos(theta)];
            case 2
                 rotMat(:,:,i) = [cos(theta),0,-sin(theta);
                                 0,1,0;
                                 sin(theta),0,cos(theta)];
            case 3
                 rotMat(:,:,i) = [cos(theta),sin(theta),0;
                                 -sin(theta),cos(theta),0;
                                 0,0,1];
        end
    end

    BN = rotMat(:,:,3)*rotMat(:,:,2)*rotMat(:,:,1);
end