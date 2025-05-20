%% Generate SIM Patterns
% Description: This MATLAB program generates the full .repz file needed for
%     structured illumination microscopy (SIM), for use in MetroCon & 
%     SIMToolbox. This program assumes you want: patterns with straight
%     lines, evenly spaced angles, pattern step size of 1 pixel, always
%     include the 0 degree angle, & 2 millisecond sequence timing 
%     (including the location of the "48455 2ms 1-bit Balanced.seq3" file).


%% Variables to change

angles = 3;
phases = 9;

% number of pixels turned on in a sequence (1 <= thickness < phases)
thickness = 1; 

% location to save .repz file
fileSavePath = 'E:\BrianL\SIM\Patterns\New\'; 

% location of the "48455 2ms 1-bit Balanced.seq3" file
seqFile = 'E:\BrianL\SIM\Patterns\48455 2ms 1-bit Balanced.seq3'; 


%% Rest of code (do NOT change)

% create the (empty) .repz folder
fileName = ['-' num2str(thickness) '-' num2str(phases-thickness,'%.2u') '-1-' num2str(phases,'%.2u')];
for angle = ((angles-1):-1:0)/angles*180
    fileName = append(num2str(angle), 'o', fileName);
end
fileName = append('lines', fileName);
mkdir([fileSavePath fileName]);

% copy the .seq3 file into the .repz folder
copyfile(seqFile, [fileSavePath fileName], 'f');

% set width & height of patterns
width = 1280;
height = 1024;

% create blank pattern
imwrite(logical(ones(height,width)), [fileSavePath fileName '\white.bmp'], 'bmp');

% create .rep file
repFile = fopen([fileSavePath fileName '\' fileName '.rep'], 'w+');
fprintf(repFile, 'SEQUENCES\n');
fprintf(repFile, 'A "48455 2ms 1-bit Balanced.seq3"\n');
fprintf(repFile, 'SEQUENCES_END\n\n');
fprintf(repFile, 'IMAGES\n');
fprintf(repFile, '1 "white.bmp"\n');
for angle = (0:(angles-1))/angles*180
    for phaseIndex = 1:phases
        fprintf(repFile, ['1 "ptrn' num2str(phaseIndex,'%.3u') '_lines' num2str(angle) 'o-' num2str(thickness) '-' num2str(phases-thickness,'%.2u') '-1-' num2str(phases,'%.2u') '.bmp"\n']); 
    end
end
fprintf(repFile, 'IMAGES_END\n\n');
fprintf(repFile, 'DEFAULT "WHITE"\n');
fprintf(repFile, '[\n');
fprintf(repFile, ' <(A,0) >\n');
fprintf(repFile, ']\n\n');
fprintf(repFile, ['"' fileName '_TF"\n']);
fprintf(repFile, '[\n');
for combinations1 = 1:(angles*phases)
    fprintf(repFile, [' <t(A,' num2str(combinations1) ') >\n']);
    fprintf(repFile, [' {f (A,' num2str(combinations1) ') }\n']);
end
fprintf(repFile, ']\n\n');
fprintf(repFile, ['"' fileName '_F"\n']);
fprintf(repFile, '[\n');
for combinations2 = 1:(angles*phases)
    fprintf(repFile, [' {f (A,' num2str(combinations2) ') }\n']);
end
fprintf(repFile, ']\n\n');
for angle = (0:(angles-1))/angles*180
    fprintf(repFile, ['"lines' num2str(angle) 'o-' num2str(thickness) '-' num2str(phases-thickness,'%.2u') '-1-' num2str(phases,'%.2u') '_TF"\n']);
    fprintf(repFile, '[\n');
    for combinations3 = 1:phases
        fprintf(repFile, [' <t(A,' num2str(combinations3) ') >\n']);
        fprintf(repFile, [' {f (A,' num2str(combinations3) ') }\n']);
    end
    fprintf(repFile, ']\n\n');
end
fclose(repFile);

% create .yaml file
yamlFile = fopen([fileSavePath fileName '\' fileName '.yaml'],'w+');
fprintf(yamlFile, ['name: ' fileName '\n']);
fprintf(yamlFile, ['imagesize: {x: ' num2str(width,'%.1f') ', y: ' num2str(height,'%.1f') '}\n']);
fprintf(yamlFile, 'sequence: 48455 2ms 1-bit Balanced.seq3\n');
fprintf(yamlFile, 'default: 0.0\n');
fprintf(yamlFile, 'runningorder:\n');
fprintf(yamlFile, '- name: WHITE\n');
fprintf(yamlFile, '  trigger: none\n');
fprintf(yamlFile, '  numseq: 1.0\n');
fprintf(yamlFile, '  data:\n');
fprintf(yamlFile, '  - id: white\n');
fprintf(yamlFile, '    num: 1.0\n');
fprintf(yamlFile, '    images: [white.bmp]\n');
for option = 1:3
    if option < 3
        if option == 1
            fprintf(yamlFile, ['- name: ' fileName '_TF\n']);
            fprintf(yamlFile, '  trigger: TF\n');
            fprintf(yamlFile, ['  numseq: ' num2str(angles*phases,'%.1f') '\n']);
            fprintf(yamlFile, '  data:\n');
        else
            fprintf(yamlFile, ['- name: ' fileName '_F\n']);
            fprintf(yamlFile, '  trigger: F\n');
            fprintf(yamlFile, ['  numseq: ' num2str(angles*phases,'%.1f') '\n']);
            fprintf(yamlFile, '  data:\n');
        end
        for angle = (0:(angles-1))/angles*180
            fprintf(yamlFile, '  - id: lines\n');
            fprintf(yamlFile, ['    angle: ' num2str(angle,'%.1f') '\n']);
            fprintf(yamlFile, ['    ''on'': ' num2str(thickness,'%.1f') '\n']);
            fprintf(yamlFile, ['    ''off'': ' num2str(phases-thickness,'%.1f') '\n']);
            fprintf(yamlFile, '    step: 1.0\n');
            fprintf(yamlFile, ['    num: ' num2str(phases,'%.1f') '\n']);
            if angle <= 90
                periodAngle = angle;
            else
                periodAngle = angle - 90;
            end
            fprintf(yamlFile, ['    period: ' num2str(phases/(cosd(periodAngle)+sind(periodAngle)),'%.17g') '\n']); 
            fprintf(yamlFile, ['    MAR: ' num2str(thickness/phases,'%.17g') '\n']); 
            fprintf(yamlFile, '    images: [');
            for phaseIndex = 1:phases
                fprintf(yamlFile, ['ptrn' num2str(phaseIndex,'%.3u') '_lines' num2str(angle) 'o-' num2str(thickness) '-' num2str(phases-thickness,'%.2u') '-1-' num2str(phases,'%.2u') '.bmp']); 
                if phaseIndex ~= phases
                    fprintf(yamlFile, ', ');
                end
            end
            fprintf(yamlFile, ']\n');
        end
    else
        for angle = (0:(angles-1))/angles*180
            fprintf(yamlFile, ['- name: lines' num2str(angle) 'o-' num2str(thickness) '-' num2str(phases-thickness,'%.2u') '-1-' num2str(phases,'%.2u') '_TF\n']);
            fprintf(yamlFile, '  trigger: TF\n');
            fprintf(yamlFile, ['  numseq: ' num2str(phases,'%.1f') '\n']);
            fprintf(yamlFile, '  data:\n');
            fprintf(yamlFile, '  - id: lines\n');
            fprintf(yamlFile, ['    angle: ' num2str(angle,'%.1f') '\n']);
            fprintf(yamlFile, ['    ''on'': ' num2str(thickness,'%.1f') '\n']);
            fprintf(yamlFile, ['    ''off'': ' num2str(phases-thickness,'%.1f') '\n']);
            fprintf(yamlFile, '    step: 1.0\n');
            fprintf(yamlFile, ['    num: ' num2str(phases,'%.1f') '\n']);
            if angle <= 90
                periodAngle = angle;
            else
                periodAngle = angle - 90;
            end
            fprintf(yamlFile, ['    period: ' num2str(phases/(cosd(periodAngle)+sind(periodAngle)),'%.17g') '\n']); 
            fprintf(yamlFile, ['    MAR: ' num2str(thickness/phases,'%.17g') '\n']); 
            fprintf(yamlFile, '    images: [');
            for phaseIndex = 1:phases
                fprintf(yamlFile, ['ptrn' num2str(phaseIndex,'%.3u') '_lines' num2str(angle) 'o-' num2str(thickness) '-' num2str(phases-thickness,'%.2u') '-1-' num2str(phases,'%.2u') '.bmp']); 
                if phaseIndex ~= phases
                    fprintf(yamlFile, ', ');
                end
            end
            fprintf(yamlFile, ']\n');
        end
    end
end
fclose(yamlFile);

% create bitmaps
for phase = 1:phases
    for angle = (0:(angles-1))/angles*180
        [x,y] = meshgrid(0:(width-1),0:(height-1));
        if angle == 45
            r = mod(x+y-phase,phases);
        elseif angle == 135
            r = mod(x-y-phase,phases);
        else
            r = mod(round(x*sind(angle)+y*cosd(angle))-phase,phases);
        end
        pattern = (r < thickness);
        imwrite(pattern, [fileSavePath fileName '\ptrn' num2str(phase,'%.3u') '_lines' num2str(angle) 'o-' num2str(thickness) '-' num2str(phases-thickness,'%.2u') '-1-' num2str(phases,'%.2u') '.bmp'], 'bmp');
    end
end

% compress .repz folder
zip([fileSavePath fileName], [fileSavePath fileName '\*']);
rmdir([fileSavePath fileName],'s');
movefile([fileSavePath fileName '.zip'], [fileSavePath fileName '.repz']);
