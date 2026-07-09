"""Histogram of writhe values over random braid words."""
import random
import matplotlib.pyplot as plt


def writhe(word):
    return sum(1 if s else -1 for _, s in word)


def random_word(length, n=4):
    return [(random.randrange(n - 1), random.random() < 0.5) for _ in range(length)]


values = [writhe(random_word(20)) for _ in range(5000)]
plt.figure(figsize=(7, 4))
plt.hist(values, bins=range(-20, 22), color="#4c72b0", edgecolor="white")
plt.title("Distribution of writhe (net directed charge) for length-20 thoughts")
plt.xlabel("writhe")
plt.ylabel("frequency")
plt.tight_layout()
plt.savefig("writhe_histogram.png", dpi=150)
print("saved writhe_histogram.png")
