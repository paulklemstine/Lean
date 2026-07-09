import matplotlib.pyplot as plt

# Bar chart of the number of odd edges among (a, b, c) across all small
# Pythagorean quadruples - the count is always 0 or 1, never 2 or 3.
counts = {0: 0, 1: 0, 2: 0, 3: 0}
for d in range(1, 60):
    for a in range(1, d):
        for b in range(a, d):
            c2 = d * d - a * a - b * b
            c = int(round(c2 ** 0.5))
            if c >= b and c > 0 and c * c == c2:
                odd = sum(1 for x in (a, b, c) if x % 2 == 1)
                counts[odd] += 1

plt.figure(figsize=(6, 4))
plt.bar(list(counts.keys()), list(counts.values()), color="indianred")
plt.title("Number of odd edges among (a, b, c) in Pythagorean quadruples")
plt.xlabel("number of odd edges"); plt.ylabel("count of quadruples")
plt.xticks([0, 1, 2, 3])
plt.tight_layout(); plt.savefig("quadruple_parity.png", dpi=140)
print("saved quadruple_parity.png")
