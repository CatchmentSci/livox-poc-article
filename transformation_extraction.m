% Sample transformation matrix
T = [0.7071 -0.7071 0 0; 0.7071 0.7071 0 0; 0 0 1 0; 2 3 4 1];

% Extracting scale
scale = sqrt(sum(T(1:3,1:3).^2));

% Extracting translation
translation = T(1:3, 4);

% Extracting Euler angles
sy = sqrt(T(1,1)^2 + T(2,1)^2);
if sy > 1e-6
    thetaX = atan2(T(3,2), T(3,3));
    thetaY = atan2(-T(3,1), sy);
    thetaZ = atan2(T(2,1), T(1,1));
else
    thetaX = atan2(-T(2,3), T(2,2));
    thetaY = atan2(-T(3,1), sy);
    thetaZ = 0;
end

% Creating rotation matrix from Euler angles
Rx = [1 0 0; 0 cos(thetaX) -sin(thetaX); 0 sin(thetaX) cos(thetaX)];
Ry = [cos(thetaY) 0 sin(thetaY); 0 1 0; -sin(thetaY) 0 cos(thetaY)];
Rz = [cos(thetaZ) -sin(thetaZ) 0; sin(thetaZ) cos(thetaZ) 0; 0 0 1];
rotation = Rx * Ry * Rz;

% Displaying the extracted values
disp('Scale:');
disp(scale);
disp('Translation:');
disp(translation');
disp('Rotation (in Euler angles):');
disp([rad2deg(thetaX) rad2deg(thetaY) rad2deg(thetaZ)]);
disp('Rotation matrix:');
disp(rotation);