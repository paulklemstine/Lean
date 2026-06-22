"""Plot a model L-function L(s) = (s-1)^r * c along the real axis for several ranks."""
import matplotlib.pyplot as plt
import numpy as np

s = np.linspace(0.0, 2.0, 400)
plt.figure(figsize=(7, 5))
for r in range(4):
    L = (s - 1.0) ** r * 1.0
    plt.plot(s, L, label=f'analytic rank r = {r}')
plt.axvline(1.0, color='gray', ls='--', lw=0.8, label='central point s = 1')
plt.axhline(0.0, color='black', lw=0.5)
plt.title('Model L-functions (s-1)^r vanishing to order r at s = 1')
plt.xlabel('s'); plt.ylabel('L(s)'); plt.legend()
plt.savefig('model_L.png', dpi=150)
print('wrote model_L.png')
