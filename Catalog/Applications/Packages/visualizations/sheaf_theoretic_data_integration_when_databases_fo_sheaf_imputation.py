def sheaf_imputation(observed, mask, max_iter=50):
    result = observed.copy()
    for c in range(observed.shape[1]):
        result[~mask[:, c], c] = np.nanmean(observed[:, c])
    for _ in range(max_iter):
        prev = result.copy()
        for c1 in range(observed.shape[1]):
            for c2 in range(c1+1, observed.shape[1]):
                both = mask[:, c1] & mask[:, c2]
                if np.sum(both) < 3: continue
                x, y = result[both, c1], result[both, c2]
                a = np.corrcoef(x,y)[0,1] * np.std(y) / np.std(x)
                b = np.mean(y) - a * np.mean(x)
                m = ~mask[:, c2] & mask[:, c1]
                result[m, c2] = 0.5*result[m, c2] + 0.5*(a*result[m, c1]+b)
        if np.max(np.abs(result - prev)) < 1e-6: break
    return result