# Computational Evidence

All numbers quoted here were first produced by scratch computation and then
**re-derived inside Lean's kernel** (`decide`) in the files
`Catalog/Shared/MoonshineJExpansion.lean` and `Catalog/Shared/MoonshineJWindow.lean`.
Nothing below is entered as unverified table data except the dimensions of the
Monster's smallest irreducible representations, which are used only inside
arithmetic identities that Lean checks.

## 1. The `q`-expansion of `j = E₄³/Δ`

Formal power series arithmetic over `ℤ`, truncated at `q^N`:

* `E₄ = 1 + 240 ∑_{n≥1} σ₃(n) qⁿ`, coefficients `1, 240, 2160, 6720, 17520, 30240, 60480, 82560, …`
* `Δ/q = ∏_{k≥1} (1 - q^k)^24`, coefficients `1, -24, 252, -1472, 4830, -6048, -16744, 84480, …`
* Dividing: `E₄³ / (Δ/q) = 1 + 744q + 196884q² + 21493760q³ + ⋯`

| `n` | coefficient `c(n)` of `qⁿ` in `j` | verified in Lean |
|----:|----------------------------------:|:----------------:|
| −1 | 1 | ✔ |
| 0 | 744 | ✔ |
| 1 | 196884 | ✔ (`j_head_coefficient`) |
| 2 | 21493760 | ✔ |
| 3 | 864299970 | ✔ |
| 4 | 20245856256 | ✔ |
| 5 | 333202640600 | ✔ |
| 6 | 4252023300096 | ✔ |
| 7 | 44656994071935 | ✔ (12-term window) |
| 8 | 401490886656000 | ✔ |
| 9 | 3176440229784420 | ✔ |
| 10 | 22567393309593600 | ✔ |

This is OEIS **A000521** (`j`-function coefficients, `c(-1) = 1`, `c(0) = 744`, …).

## 2. Ramanujan tau

The same eta-product computation yields `τ(1..12)`:

`1, -24, 252, -1472, 4830, -6048, -16744, 84480, -113643, -115920, 534612, -370944`

which is OEIS **A000594**.  Checks performed on these *computed* values (all
re-verified in Lean):

* multiplicativity `τ(2)τ(3) = τ(6)`: `(-24)(252) = -6048` ✔
* `τ(4) = τ(2)² - 2¹¹ = 576 - 2048 = -1472` ✔
* `τ(8) = τ(2)τ(4) - 2¹¹τ(2) = 35328 + 49152 = 84480` ✔
* `τ(9) = τ(3)² - 3¹¹ = 63504 - 177147 = -113643` ✔
* `τ(10) = τ(2)τ(5) = -115920` ✔, `τ(12) = τ(3)τ(4) = -370944` ✔
* Ramanujan's congruence `τ(n) ≡ σ₁₁(n) (mod 691)` for `n ≤ 12`:
  residues `1, 667, 252, 601, 684, 171, 531, 178, …` match on both sides ✔
* Lehmer non-vanishing `τ(n) ≠ 0` for `n ≤ 12` ✔ (no counterexample found, as expected)

## 3. McKay-type decompositions

Searching for non-negative integer combinations of the Monster irreducible
dimensions `1, 196883, 21296876, 842609326, 18538750076, 19360062527,
293553734298, 3879214937598` reproducing the verified `c(n)` gave a unique
greedy solution at each level:

```
196884        = 1 + 196883
21493760      = 1 + 196883 + 21296876
864299970     = 2·1 + 2·196883 + 21296876 + 842609326
20245856256   = 2·1 + 3·196883 + 2·21296876 + 842609326 + 19360062527
333202640600  = 3·1 + 5·196883 + 4·21296876 + 842609326 + 2·19360062527 + 293553734298
4252023300096 = 3·1 + 7·196883 + 6·21296876 + 2·842609326 + 4·19360062527
                + 293553734298 + 3879214937598
```

Each identity is checked by the Lean kernel against the *computed* `c(n)`, so a
wrong recollection of a dimension would have produced a build failure.

## 4. Counterexample hunt on the finite check

The reduction says the degree `-192` coefficient of the `194`-fold product is
`∑_g c_g(1)`.  Random integral tables were tested against the elementary
symmetric expansion: with entries drawn in `[-10, 10]` the coefficient at
`2k - 194` always matched `e_k` of the table, for `k ≤ 3`.  No counterexample
appeared, and the general statement is now proved
(`MoonshineHeadRigidity.coeff_headProduct_esymm`), so the search is subsumed.

## 5. Caveat on the `194` entries

The Monster's full head table `c_g(1) = 1 + χ_{196883}(g)` requires the ATLAS
character values for all `194` classes.  Only the `1A` entry (`196884`) is
derivable from first principles by the computation above, so only that entry is
asserted in the formal development; the illustrative `194`-entry table in
`MoonshineHeadTable.demoTable` is explicitly labelled as a mechanism
demonstration, with placeholders outside `1A`.
