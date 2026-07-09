import matplotlib.pyplot as plt


def anti_fib_closed(k: int) -> int:
    return 1 + k * (k - 1) // 2


N = 15
ks = list(range(N))
vals = [anti_fib_closed(k) for k in ks]
diffs = [vals[k + 1] - vals[k] for k in range(N - 1)]
plt.figure(figsize=(8, 5))
markerline, stemlines, baseline = plt.stem(range(N - 1), diffs)
plt.setp(markerline, markersize=8)
for k, d in enumerate(diffs):
    plt.annotate(str(d), (k, d + 0.2), ha='center')
plt.xlabel('index k')
plt.ylabel('A(k+1) - A(k)')
plt.title('First differences are exactly 0, 1, 2, 3, ...')
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('first_differences.png', dpi=150)
print('saved first_differences.png')
