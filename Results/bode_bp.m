pkg load signal
fs = 125e6/8;
fc1 = 2e6;
fc2 = 2.5e6;
b = fir1(30, [fc1 fc2]/(fs/2), 'bandpass');
[h, w] = freqz(b, 1, 4096);
mag = 20*log10(abs(h));
wn = w/pi;
[~, im] = max(mag);                          % maximum de la bande
[~, i1] = min(abs(mag(1:im) + 6));           % -6 dB cote bas
[~, i2] = min(abs(mag(im:end) + 6)); i2 = i2 + im - 1;   % -6 dB cote haut
fprintf('wn1 = %.4f -> %.3f MHz, wn2 = %.4f -> %.3f MHz, max a %.3f MHz\n', wn(i1), wn(i1)*fs/2/1e6, wn(i2), wn(i2)*fs/2/1e6, wn(im)*fs/2/1e6);
figure(1)
plot(wn, mag, 'linewidth', 1.5)
hold on
plot([wn(i1) wn(i1)], [-80 mag(i1)], 'r--')
plot([wn(i2) wn(i2)], [-80 mag(i2)], 'r--')
plot([0 1], [-6 -6], 'r--')
plot([wn(i1) wn(i2)], [mag(i1) mag(i2)], 'ro', 'markersize', 8, 'linewidth', 2)
text(wn(i1)-0.2, -15, sprintf('wn = %.3f\nf = %.3f MHz', wn(i1), wn(i1)*fs/2/1e6))
text(wn(i2)+0.03, -15, sprintf('wn = %.3f\nf = %.3f MHz', wn(i2), wn(i2)*fs/2/1e6))
grid on
axis([0 1 -80 5])
xlabel('frequence normalisee (x pi rad/echantillon)')
ylabel('amplitude (dB)')
title('Passe-bande ordre 30 : coupures reelles a -6 dB')
print -dpng 'bode_passe_bande.png'
