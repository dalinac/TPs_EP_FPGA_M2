import numpy as np
import matplotlib.pyplot as plt

N = 10
fmclk = 125e6
df = fmclk/2**N     # 122,07 kHz

W = 16
Wh = 1024 - W       # 1008, au dela de 512

# meme calcul que la table du vhdl
def sortie(w, n, offset=0):
    k = (np.arange(n)*w + offset) % 2**N
    return np.round((2**14-1)*(1 + np.sin(2*np.pi*k/2**N))/2)

# ---- figure 1 : temporel ----
n = 80
t = np.arange(n)/fmclk*1e9
tc = np.linspace(0, n/fmclk, 4000)*1e9

plt.figure(figsize=(8, 4))
plt.plot(tc, (2**14-1)*(1+np.sin(2*np.pi*Wh*df*tc*1e-9))/2, lw=0.6, color='grey',
         label='sinus voulu pour W = 1008 (123,05 MHz)')
plt.plot(tc, (2**14-1)*(1+np.sin(2*np.pi*W*df*tc*1e-9))/2,
         label='sinus pour W = 16 (1,95 MHz)')
plt.plot(t, sortie(Wh, n), 'o', ms=4, label='echantillons du DDS pour W = 1008')
plt.xlabel('temps (ns)')
plt.ylabel('amplitude (14 bits)')
plt.title('Repliement : W = 1008 et W = 16 ont la meme periode')
plt.legend(fontsize=8)
plt.grid()
plt.savefig('repliement_temporel.png', dpi=150, bbox_inches='tight')

# ---- figure 2 : frequentiel ----
n = 4096
y = sortie(Wh, n)
y = y - y.mean()
Y = abs(np.fft.rfft(y*np.hanning(n)))
f = np.fft.rfftfreq(n, 1/fmclk)
m = 20*np.log10(Y/max(Y) + 1e-12)

# le spectre se repete : image a fmclk - f
f2 = np.concatenate([f, fmclk - f[::-1]])/1e6
m2 = np.concatenate([m, m[::-1]])

plt.figure(figsize=(8, 4))
plt.plot(f2, m2)
plt.axvline(62.5, color='red')
plt.text(64, 0, 'fmclk/2', color='red')
plt.axvspan(0, 50, color='green', alpha=0.1)
plt.text(85, -25, 'raie voulue : 123,05 MHz')
plt.text(5, -35, 'image : 1,95 MHz')
plt.xlim(0, 125)
plt.ylim(-70, 10)
plt.xlabel('frequence (MHz)')
plt.ylabel('amplitude (dB)')
plt.title('Spectre du DDS pour W = 1008')
plt.grid()
plt.savefig('spectre_repliement.png', dpi=150, bbox_inches='tight')
