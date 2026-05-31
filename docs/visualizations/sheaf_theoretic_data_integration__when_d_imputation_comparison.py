import numpy as np
import matplotlib.pyplot as plt

def sheaf_impute(observed, mask, max_iter=50, tol=1e-6):
    n_rows, n_cols = observed.shape
    result = observed.copy()
    for c in range(n_cols):
        col_mean = np.nanmean(observed[:, c]) if np.any(mask[:, c]) else 0.0
        result[~mask[:, c], c] = col_mean
    for _ in range(max_iter):
        prev = result.copy()
        for c1 in range(n_cols):
            for c2 in range(c1 + 1, n_cols):
                both_obs = mask[:, c1] & mask[:, c2]
                if np.sum(both_obs) < 3: continue
                x, y = result[both_obs, c1], result[both_obs, c2]
                sx, sy = np.std(x), np.std(y)
                if sx < 1e-10 or sy < 1e-10: continue
                a = np.corrcoef(x, y)[0, 1] * sy / sx
                b = np.mean(y) - a * np.mean(x)
                m2 = ~mask[:, c2] & mask[:, c1]
                result[m2, c2] = 0.5 * result[m2, c2] + 0.5 * (a * result[m2, c1] + b)
                m1 = ~mask[:, c1] & mask[:, c2]
                if abs(a) > 1e-10:
                    result[m1, c1] = 0.5 * result[m1, c1] + 0.5 * (result[m1, c2] - b) / a
        if np.max(np.abs(result - prev)) < tol: break
    return result

def main():
    np.random.seed(42)
    n_rows, n_cols = 200, 10
    latent = np.random.randn(n_rows, 3)
    A = np.random.randn(3, n_cols)
    gt = latent @ A + 0.1 * np.random.randn(n_rows, n_cols)
    rates = np.arange(0.05, 0.65, 0.05)
    rmse_m, rmse_s = [], []
    for mr in rates:
        mask = np.random.rand(n_rows, n_cols) > mr
        obs = gt.copy(); obs[~mask] = np.nan
        imp_m = obs.copy()
        for c in range(n_cols):
            imp_m[~mask[:, c], c] = np.nanmean(obs[:, c]) if np.any(mask[:, c]) else 0
        imp_s = sheaf_impute(obs, mask)
        missing = ~mask
        rmse_m.append(np.sqrt(np.mean((imp_m[missing] - gt[missing]) ** 2)))
        rmse_s.append(np.sqrt(np.mean((imp_s[missing] - gt[missing]) ** 2)))
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    axes[0].plot(rates*100, rmse_m, 'o-', label='Mean', color='tab:blue')
    axes[0].plot(rates*100, rmse_s, 's-', label='Sheaf', color='tab:red')
    axes[0].set_xlabel('Missing Rate (%)')
    axes[0].set_ylabel('RMSE')
    axes[0].set_title('Imputation Error: Sheaf vs. Mean')
    axes[0].legend(); axes[0].grid(True, alpha=0.3)
    imp_pct = [(m-s)/m*100 for m,s in zip(rmse_m, rmse_s)]
    axes[1].bar(rates*100, imp_pct, width=4, color='tab:green', alpha=0.7)
    axes[1].set_xlabel('Missing Rate (%)')
    axes[1].set_ylabel('Improvement (%)')
    axes[1].set_title('Sheaf Imputation Advantage')
    axes[1].axhline(y=0, color='black', lw=0.5); axes[1].grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig('viz_imputation_comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print('Saved viz_imputation_comparison.png')

if __name__ == '__main__':
    main()