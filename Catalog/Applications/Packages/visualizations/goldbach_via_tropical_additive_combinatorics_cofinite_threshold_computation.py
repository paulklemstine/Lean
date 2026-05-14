def cofinite_threshold(exceptions):
    if not exceptions:
        return 0
    return 2 * (max(exceptions) + 1)

# Verify
def trop_conv(f, g, n):
    result = None
    for a in range(n + 1):
        fa, gb = f(a), g(n - a)
        if fa is not None and gb is not None:
            val = fa + gb
            if result is None or val < result:
                result = val
    return result

exceptions = {0, 1, 2, 3, 4}
threshold = cofinite_threshold(exceptions)
A = set(range(100)) - exceptions
f = lambda n: 0 if n in A else None

print(f"Exceptions: {sorted(exceptions)}")
print(f"Threshold: {threshold}")
for n in range(threshold - 2, threshold + 10):
    val = trop_conv(f, f, n)
    status = "= 0 ✓" if val == 0 else "= ⊤"
    print(f"  tropConv(A,A)({n}) {status}")
