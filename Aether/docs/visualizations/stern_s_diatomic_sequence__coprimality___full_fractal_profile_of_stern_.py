import matplotlib.pyplot as plt
from typing import List


def stern_table(limit: int) -> List[int]:
    s = [0] * (limit + 1)
    if limit >= 1:
        s[1] = 1
    for k in range(1, limit // 2 + 1):
        if 2 * k <= limit:
            s[2 * k] = s[k]
        if 2 * k + 1 <= limit:
            s[2 * k + 1] = s[k] + s[k + 1]
    return s


N = 1023
s = stern_table(N)
plt.figure(figsize=(12, 4))
plt.plot(range(N + 1), s, linewidth=0.7)
plt.title("Stern's diatomic sequence s(n), n = 0..1023")
plt.xlabel("index n")
plt.ylabel("s(n)")
plt.tight_layout()
plt.savefig("stern_plot.png", dpi=150)
print("wrote stern_plot.png")
