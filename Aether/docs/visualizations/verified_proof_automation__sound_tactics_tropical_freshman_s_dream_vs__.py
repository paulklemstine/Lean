import numpy as np
import matplotlib.pyplot as plt

a = 1.0
b = np.linspace(-4, 6, 400)
trop_sq_of_sum = np.minimum(2*a, 2*b)          # (a (+) b)^2
trop_sum_of_sq = np.minimum(2*a, 2*b)          # a^2 (+) b^2
ordinary = (a + b)**2                            # classical (a+b)^2
plt.figure(figsize=(8, 5))
plt.plot(b, trop_sq_of_sum, lw=3, label='tropical (a (+) b)^2')
plt.plot(b, trop_sum_of_sq, '--', lw=2, label='tropical a^2 (+) b^2')
plt.plot(b, ordinary, ':', label='ordinary (a+b)^2')
plt.xlabel('b'); plt.ylabel('value'); plt.title("Tropical Freshman's Dream (a=1)")
plt.legend(); plt.grid(True, alpha=0.3)
plt.tight_layout(); plt.savefig('tropical_freshman.png', dpi=150)
print('saved tropical_freshman.png')
