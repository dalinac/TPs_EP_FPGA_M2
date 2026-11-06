pkg load signal
fs = 125e6/8; % 15,625 MHz
fc = 0.5e6; % coupure demandee a -6 dB
b = fir1(4, fc/(fs/2), 'low')
sum(b) % = 1 : gain unite en continu
figure(1)
freqz(b) % Bode : relever la frequence a -6 dB

% ---------------------------------------------------------------
% De la frequence lue sur le graphe a la frequence reelle
%
% freqz trace l'axe x en frequence NORMALISEE wn, qui va de 0 a 1 :
% la valeur 1 correspond a pi rad/echantillon, c'est-a-dire a fs/2.
% Pour convertir une valeur lue sur cet axe :
%
%        f = wn * fs/2        avec fs/2 = 7,8125 MHz
%
% ex : au point -6 dB on lit wn = 0,4238
%      f = 0,4238 * 7,8125e6 = 3,31 MHz  (et non 0,5 MHz)
% ---------------------------------------------------------------

[h, w] = freqz(b);             % w en rad/echantillon, de 0 a pi
mag = 20*log10(abs(h));
wn = w/pi;                     % meme axe que celui trace par freqz(b)

[~, i6] = min(abs(mag + 6));   % point le plus proche de -6 dB
wn6 = wn(i6);
f6 = wn6 * fs/2;               % conversion : wn -> Hz

fprintf('coupure -6 dB : wn = %.4f  ->  f = %.3f MHz\n', wn6, f6/1e6);

% ---- meme trace avec un curseur sur le point -6 dB ----
figure(2)
plot(wn, mag, 'linewidth', 1.5)
hold on
plot([wn6 wn6], [-40 mag(i6)], 'r--')   % curseur vertical
plot([0 wn6], [-6 -6], 'r--')           % curseur horizontal a -6 dB
plot(wn6, mag(i6), 'ro', 'markersize', 8, 'linewidth', 2)
text(wn6+0.04, -12, sprintf('wn = %.4f', wn6))
text(wn6+0.04, -16, sprintf('f = %.2f MHz', f6/1e6))
grid on
axis([0 1 -40 5])
xlabel('frequence normalisee (x pi rad/echantillon)')
ylabel('amplitude (dB)')
title('Passe-bas ordre 4 : coupure reelle a -6 dB')
print -dpng 'coupure_passe_bas.png'
