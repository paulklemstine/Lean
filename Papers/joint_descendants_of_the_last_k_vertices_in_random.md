# Computational Evidence — Joint descendants of the last `k` vertices in random `d`-DAGs

All checks below were computed exactly over `ℚ` before the formal proofs were written.
The relevant objects:

* Integer moment of `Beta(a,b)`: `betaMom a b m = ∏_{j<m} (a+j)/(a+b+j)` (rising-factorial ratio).
* Ancestry / Pólya-urn expectation: `urnExpected β γ n = ∏_{i<n} (1 + γ/(β+i))`.

## 1. Beta-chain moment telescoping

Claim: for a chain `a₀ = 1, b₀ = 2, a₁ = a₀+b₀ = 3, b₁ = 1` (so `a₂ = 4`), the product of the
two Beta moments equals a single Beta moment with second parameter `∑ bᵢ = 3`:

```
betaMom 1 2 3 * betaMom 3 1 3  =  1/20
betaMom 1 3 3                  =  1/20      ✓ (equal)
```

More generally the double product `∏ᵢ ∏ⱼ (aᵢ+j)/(aᵢ+bᵢ+j)` collapses because the inner product
over `i` telescopes (`aᵢ + bᵢ = aᵢ₊₁`), leaving `(a₀+j)/(a_r+j)` with `a_r = a₀ + ∑ bᵢ`.

## 2. Gamma closed form of the urn expectation

For an **integer** reinforcement `γ = 1` the product telescopes to `(β+n)/β`, a clean sanity
check of the general Gamma identity `∏_{i<n}(1+γ/(β+i)) = Γ(β)Γ(β+γ+n)/(Γ(β+γ)Γ(β+n))`:

```
urnExpected 2 1 5   =  7/2   =  (β+n)/β = (2+5)/2     ✓
```

(For non-integer `γ`, e.g. `γ = d/(d+1)`, the same identity holds with genuine Gamma values; it
is proved by induction using `Γ(x+1) = x·Γ(x)`.)

## 3. Non-degeneracy (positive variance)

For `Beta(2,3)`:

```
second moment  betaMom 2 3 2      =  1/5   =  5/25
(first moment)² (betaMom 2 3 1)²  =  4/25
5/25 > 4/25                                   ✓  ⇒  variance > 0
```

The strict gap is driven by the extra `+b` term in `(a+1)(a+b) − a(a+b+1) = b > 0`.

## 4. Scaling exponent

`γ_d = d/(d+1)` for `d = 1,2,3,4` gives `1/2, 2/3, 3/4, 4/5`, strictly increasing towards `1`,
and each is the unique solution of the Malthusian balance `(d+1)·x = d`.

## 5. Counterexample hunt

No counterexamples were found. The telescoping identity was checked on several chains
(varying `r`, `m`, and the `bᵢ`), the urn identity on integer `γ = 1,2,3`, and the
non-degeneracy inequality on many `(a,b)` with `a,b > 0`; all agreed with the formulas above.
