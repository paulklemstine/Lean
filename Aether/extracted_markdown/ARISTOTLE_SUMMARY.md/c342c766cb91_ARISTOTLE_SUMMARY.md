# Summary of changes for run b5f1d94a-09f3-43b8-9021-688b29f9639e
Built a complete, sorry-free Korselt factorization-coordinate-domination bridge plus the optional Berggren shear computation. All theorems compile under `lake build` and depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound`.

New file `Catalog/Bridges/KorseltFactorizationBridge.lean` (main deliverable):
- `dvd_iff_factorization_le {a b : ℕ} (ha : a ≠ 0) (hb : b ≠ 0) : a ∣ b ↔ ∀ p, a.factorization p ≤ b.factorization p` — Main target 1. This is the exact "divisibility = coordinatewise domination of prime-exponent vectors" statement. I use the strongest clean version requiring both arguments nonzero; with `b = 0` the unrestricted statement is false (documented in the module comments).
- Helper lemmas `intCast_dvd_sub_pow_iff` (read integer divisibility by a prime in `ZMod p`), `squarefree_intDvd_iff` (squarefree CRT: divisibility by `n` iff by each prime factor), and `fermat_prime_local_iff` (local Korselt at a prime: `a^n ≡ a (mod p)` for all `a` iff `(p-1) ∣ (n-1)`).
- `Carmichael n := ∀ a : ℤ, (n:ℤ) ∣ a^n - a` (the absolute Fermat congruence — the property Korselt characterizes).
- `korselt_criterion : Carmichael n ↔ Squarefree n ∧ ∀ p, p.Prime → p ∣ n → (p-1) ∣ (n-1)` — Korselt's criterion, proved from scratch with no side hypotheses (the existing "Carmichael" material in the project is about Fibonacci primitive divisors, and Mathlib has no Carmichael numbers, so this was built fresh).
- `korselt_iff_factorization_domination : Carmichael n ↔ Squarefree n ∧ ∀ p, p.Prime → p ∣ n → ∀ q, (p-1).factorization q ≤ (n-1).factorization q` — Main target 2, the actual bridge: every divisibility clause of Korselt is converted into coordinatewise factorization-exponent domination.

The module docstring documents the design choices for the degenerate inputs (`n = 0` makes both sides false, `n = 1` vacuously true; primes also satisfy the predicate by Fermat's little theorem, so genuine Carmichael numbers are the composite members), and explicitly avoids any metaphorical "tropicalFlat" definition.

Optional secondary target — new file `Catalog/EML/BerggrenShearPower.lean`, kept fully separate so it cannot affect the main result. It reuses the exact shear matrix `berggren_M₃' = !![1,2;0,1]` from `EML/LatticeTreeCorrespondence` and proves:
- `berggren_M₃'_pow (k : ℕ) : berggren_M₃' ^ k = !![1, 2*k; 0, 1]` (exact power formula), with corollary `berggren_M₃'_pow_upperRight : (berggren_M₃' ^ k) 0 1 = 2*k`.
- `berggren_M₃'_pow_mod_eq_one_iff (m k : ℕ) : (berggren_M₃' ^ k).map (Int.cast : ℤ → ZMod m) = 1 ↔ (m:ℤ) ∣ 2*k` (modular triviality criterion).

I also fixed a pre-existing build misconfiguration in `lakefile.toml`: the library globs reference modules at the package root, but all sources live under `Catalog/`, so `lake build` could not locate any file. Adding `srcDir = "Catalog"` makes the whole project build correctly (this matches the actual file layout and only enables building; it removes nothing).