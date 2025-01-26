
a = categorical({'8192','16384','32768','65536','131072'});
a = reordercats(a,{'8192','16384','32768','65536','131072'});
b = [975,  971,  995,  1012, nan;
     1489,  1324,  1567,  1608, 1639;
    2576, 2643, 2703,  2779, 2833;
     nan, nan, 4880,  5010, 5161
];


plot(a,b,'-s',LineWidth=2);

ax = gca;
ax.YGrid = 'on';
h_old = ax.YAxis;
h = ax;
ylabel(h,"Absolute Anzahl von FF");
xlabel(h,"Anzahl von Einträgen (30 bit)");


% Ausgangsachsen
p = get(h, 'position');

% Neue Achsen zeichnen
h2 = axes('position', p, 'color', 'none'); % Zeichnet eine weitere Achse mit transparentem Hintergrund über h
h2.YLim = ylim(h); % Setzt die gleichen Grenzen wie in h
hold on;
box off;

% Achseneinstellungen für die neue Achse
set(h2, 'XTick', [], 'YAxisLocation', 'right');

M = str2double(get(h, 'YTickLabel'));
M2 = round((M./548160).*100,2);
M3 = num2cell(M2);
set(h2, 'YTickLabel', M3);
ylabel(h2,"Relative Anzahl von FF (in %)");

hold off;