# Summary of changes for run 3493c932-1955-4038-a801-dabbd2bcc2d2
I added a new, self-contained Lean development extending the LWE search-to-decision formalization with a **Rényi divergence toolkit for lattice cryptography**.

**New files (under `Catalog/Cryptography/LWE/`):**
- `RenyiDivergence.lean` — 13 theorems + 2 supporting definitions/lemmas, all proved with **zero `sorry`** and depending only on the standard axioms (`propext`, `Classical.choice`, `Quot.sound`). Each block carries a 1–2 sentence proof sketch.
- `FUTURE_DIRECTIONS.md` — 5 falsifiable research conjectures, each with a "The key insight is…" sentence and a "Why now?" justification.

**Definition.** `renyiDiv α P Q = ∑ₓ P(x)^α · Q(x)^{1-α}`, the multiplicative Rényi divergence over a finite index set.

**Main proved theorems:**
1. `renyiDiv_nonneg`, `renyiDiv_self`, `renyiDiv_self_prob` — basic structure (non-negativity; diagonal value `∑P`, hence `1` for a probability law).
2. `renyiDiv_multiplicative` — multiplicativity under independent products (the composition rule for multi-sample noise).
3. `renyiDiv_pow_of_iid` (with helper `sum_prod_pow`) — the `m`-fold tensor power: i.i.d. divergence is `RD_α(P‖Q)^m`.
4. `renyiDiv_two_uniform_eq_collision` — order-2 vs. uniform equals `N·∑P²`, the bridge to collision probability / leftover hashing.
5. **Centerpiece — Gaussian shift identity**: `gaussian_renyi_completion` (completion-of-squares engine), `gaussian_renyi_pointwise`, and `gaussian_renyiDiv_shift` give the exact factorization `RD_α = exp(-π α(1-α)c²/s²)·∑ᵢ ρ_s(latt i − αc)`; `gaussian_renyi_prefactor_le_one` and `gaussian_renyiDiv_flooding` deliver the noise-flooding bound for `0 ≤ α ≤ 1`.
6. `pigeonhole_bound_tight` — tightness of the factor-`n` search-to-decision advantage loss.
7. For the best result, a strengthening (`renyiDiv_pow_of_iid`) and a boundary counterexample (`renyiDiv_multiplicative_needs_independence`, witnessed by a perfectly-correlated law over `Bool²`) showing the independence hypothesis is essential.

Every theorem was checked through the language server against the project's Mathlib; the file is free of `sorry` and uses no non-standard axioms. (Note: I avoided a worst-case ML-KEM "decryption always correct" claim because that statement is false for real Kyber parameters — its security relies on a small decryption-failure probability — so I focused on the rigorously provable Rényi-divergence machinery instead.)