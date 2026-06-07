def ultrafilter_decide(prop, N=100000, threshold=0.9):
    count = sum(1 for i in range(N) if prop(i))
    return count / N > threshold