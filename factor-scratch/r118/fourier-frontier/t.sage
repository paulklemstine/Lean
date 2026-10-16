set_random_seed(3)
print("random() values:", [random() for _ in range(6)], flush=True)
print("random() < 1.0:", [random() < 1.0 for _ in range(6)], flush=True)
k = 257353
block = ((1 << 4) - 1)
notblock = ((1 << 18) - 1) ^ block
print("k =", k, " block =", block, " notblock =", notblock, type(notblock), flush=True)
print("k & notblock =", k & notblock, "  (k & block) after =", (k & notblock) & block, flush=True)
k2 = int(k)
print("python int & sage:", k2 & notblock, (k2 & notblock) & block, flush=True)
