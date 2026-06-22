import matplotlib.pyplot as plt

WITNESS = {3:2,4:3,5:5,7:13,8:7,9:17,10:11,11:89,13:233,14:29,15:61,
  16:47,17:1597,18:19,19:37,20:41,21:421,22:199,23:28657,24:23,25:3001,
  26:521,27:53,28:281,29:514229,30:31,31:557,32:2207,33:19801,34:3571,
  35:141961,36:107,37:73,38:9349,39:135721,40:2161}
ns = sorted(WITNESS)
ys = [WITNESS[n] for n in ns]
plt.figure(figsize=(11, 6))
plt.semilogy(ns, ys, 'o-', color='crimson')
for n in (1, 2, 6, 12):
    plt.axvline(n, color='gray', ls='--', alpha=0.5)
plt.xlabel('index n'); plt.ylabel('least primitive prime divisor of F(n)')
plt.title('Carmichael witnesses (dashed = exceptions 1,2,6,12)')
plt.grid(True, which='both', alpha=0.3)
plt.tight_layout(); plt.savefig('primitive_growth.png', dpi=150)
print('saved primitive_growth.png')
