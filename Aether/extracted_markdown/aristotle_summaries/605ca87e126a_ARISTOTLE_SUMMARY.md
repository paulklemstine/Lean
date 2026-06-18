# Summary of changes for run 2bee8ca5-d6f8-4031-a8dd-49431a2d3464
## What I did

This cycle worked on the Fibonacci primitive-divisor / Carmichael program, closing proofs and adding new duality/representation theory. All new results compile with `sorry = 0` and use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### 1. Made the project build again (it previously did not)
- The Carmichael development imported `Shared.CarmichaelHelper`, a file that **did not exist**, and referenced `fib_primitive_divisor_prime`, an **undefined** declaration — so `Shared/CarmichaelProof.lean` and `Speculative/AutoResearch/CarmichaelComposite.lean` could not compile.
- The build also resolved no source modules because the lakefiles lacked a `srcDir` and library entries for several source directories. I added `srcDir = "Catalog"` to the outer lakefile and `lean_lib` entries for `Applications`, `Novelty`, and `Catalog` to both lakefiles (additive; default build targets unchanged).

### 2. Closed the prime-index case of Carmichael's theorem (new file `Catalog/Shared/CarmichaelHelper.lean`)
- Proved `fib_primitive_divisor_prime`: for a prime index `n ≥ 13`, `F n` has a primitive prime divisor. The proof is the rank-of-apparition argument — any prime dividing `F n` has rank dividing the prime `n`, and rank `1` is impossible, so the rank is `n`. This was the missing piece that the composite-case file depends on.

### 3. New duality / representation theory (new file `Catalog/Applications/FibonacciRankDuality.lean`)
Building on the catalog's `Applications/RankOfApparition.lean`, I formalized the rank of apparition as one side of a Galois adjunction `fibRank ⊣ fib`:
- `fibRank_dvd_iff'` — the spine `fibRank m ∣ n ↔ m ∣ F n` for **every** `m` (removes the `HasFibRank` hypothesis of the catalog version).
- `fibRank_lcm` — `fibRank` is an exact lcm (join) homomorphism: `fibRank (lcm a b) = lcm (fibRank a) (fibRank b)`.
- `fibRank_finset_lcm` — the join homomorphism over arbitrary finite families.
- `fibRank_mono` and `fibRank_gcd_dvd` — the one-sided meet (gcd) law `fibRank (gcd a b) ∣ gcd (fibRank a) (fibRank b)`.

Each file contains Lab Notebook blocks (Hypothesis / Result / Insight / Failure) and per-theorem proof sketches in `-- !-- ... -- !--` form.

### 4. `FUTURE_DIRECTIONS.md`
A narrative with a results summary and four falsifiable directions (each with a "key insight" and "why now"), headlined by a precise reduction of the one remaining open case.

## Remaining open item (honest status)
One pre-existing `sorry` remains: the **composite asymptotic tail** `fib_carmichael_composite` for `n > 10000` in `Catalog/Shared/CarmichaelProof.lean` (the band `13 ≤ n ≤ 10000` is already certified computationally). This is Carmichael's deep composite case; a focused attempt confirmed it is not closable without first building the homogeneous cyclotomic value `Φ_n` (Möbius product identity, an intrinsic-prime lemma from lifting-the-exponent, and a golden-ratio size bound `Φ_n > n`). `FUTURE_DIRECTIONS.md` records this reduction in full as the primary next step, noting that all needed analytic ingredients already exist sorry-free elsewhere in the catalog.