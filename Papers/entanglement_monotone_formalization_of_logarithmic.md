# Computational Evidence

All numbers below were produced by `#eval` inside Lean 4 (Mathlib v4.28.0) with **exact
rational arithmetic** (`ℚ`), so they are exact, not floating point. The script is reproduced
at the end of this file and can be run with `lake env lean <file>` from the `Catalog/`
directory.

## 1. Test family

Two qubits, index type `Fin 2 × Fin 2`, isotropic (Werner-type) family

```
ρ_p  =  p · Φ  +  (1 − p)/4 · I ,      Φ = |Φ⁺⟩⟨Φ⁺| ,  |Φ⁺⟩ = (|00⟩ + |11⟩)/√2 ,
```

with partial transpose `Γ` on the second factor.

Sanity check (`#eval`): `tr Φ = 1`, `tr ρ_1 = 1`, `tr ρ_{1/2} = 1`.

## 2. Spectrum of the partial transpose

Predicted eigenvalues of `Γρ_p`: `(p+1)/4` (three times) and `(1−3p)/4` (once).
The prediction was tested by evaluating the **exact determinant**
`det(Γρ_p − λ I)` at the predicted values:

| p | λ = (p+1)/4 | det(Γρ_p − λI) | λ = (1−3p)/4 | det(Γρ_p − λI) |
|---|---|---|---|---|
| 1 | 1/2 | **0** | −1/2 | **0** |
| 2/3 | 5/12 | **0** | −1/4 | **0** |
| 1/2 | 3/8 | **0** | −1/8 | **0** |
| 1/3 | 1/3 | **0** | 0 | **0** |

Every determinant vanishes exactly, confirming the spectrum.

## 3. Trace norm and logarithmic negativity

From the spectrum, `‖Γρ_p‖₁ = 3(p+1)/4 + |1−3p|/4`:

| p | ‖Γρ_p‖₁ (exact) | E_N = log‖Γρ_p‖₁ | PPT? |
|---|---|---|---|
| 1 | 2 | log 2 ≈ 0.6931 | no |
| 2/3 | 3/2 | log 1.5 ≈ 0.4055 | no |
| 1/2 | 5/4 | log 1.25 ≈ 0.2231 | no |
| 1/3 | 1 | 0 | yes |

The threshold `p = 1/3` is exactly where the smallest eigenvalue `(1−3p)/4` changes sign,
i.e. where the state becomes PPT and `E_N` hits `0`. This is the numerical face of the
formalised statement `EntMonotone.isPPT_iff_logNeg_eq_zero`.

The maximum value `E_N(ρ_1) = log 2 = log d` for `d = 2` agrees with the formalised exact
value `EntMonotone.logNeg_maxEntangled` and saturates the ceiling
`EntMonotone.logNeg_le_log_dim` (`½ log(2·2) = log 2`), confirming the sharpness statement
`EntMonotone.logNeg_le_logNeg_maxEntangled`.

## 4. Swap-operator structure

`#eval` confirms, for `d = 2`:

* `S · S = 1` where `S` is the swap matrix — `true`;
* `tr S = 2`;
* `Γρ_1 = ½ · S` — `true`.

This is exactly the identity used in `EntMonotone.ptrans_maxEntangled` and, with
`‖S‖₁ = d² = 4`, gives `‖Γ Φ_d‖₁ = d = 2`.

## 5. Hilbert–Schmidt invariance under partial transposition

The dimensional ceiling relies on `tr((Γρ)²) = tr(ρ²)`. Exact `#eval`:

| p | tr((Γρ_p)²) | tr(ρ_p²) |
|---|---|---|
| 1 | 1 | 1 |
| 1/2 | 7/16 | 7/16 |

Both agree, as proved in `EntMonotone.trace_ptrans_sq`.

## 6. Counterexample hunt

* **Additivity of `E_N`** — for the family above, `‖Γ(ρ_p ⊗ ρ_q)‖₁ = ‖Γρ_p‖₁ ‖Γρ_q‖₁`
  because the partial transpose of the tensor product is the tensor product of the partial
  transposes and the spectrum of a Kronecker product is the product of the spectra
  (e.g. `p = 1/2`, `q = 2/3` gives `5/4 · 3/2 = 15/8`, so `E_N` adds). No counterexample was
  found, and the general statement is now proved: `EntMonotone.logNeg_tensorBipartite`.
* **Additivity of the negativity `N`** — fails already at `p = q = 1`:
  `N(ρ_1) = 1/2` but `N(ρ_1 ⊗ ρ_1) = (4−1)/2 = 3/2 ≠ 1`. This matches the exact law
  `N(ρ⊗σ) = 2N(ρ)N(σ) + N(ρ) + N(σ)` (`EntMonotone.negativity_tensorBipartite`):
  `2·(1/2)(1/2) + 1/2 + 1/2 = 3/2`. ✔
* **Trying to break the ceiling** — no member of the family exceeds `log 2`; the maximum
  `‖Γρ_p‖₁ = 2` is attained only at `p = 1`.
* No OEIS-type integer sequence arises here; the objects are continuous families of
  matrices, so an OEIS search is not applicable.

## 7. Script

```lean
import Mathlib
open Matrix

def Phi : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℚ :=
  Matrix.of fun p q => (1/2 : ℚ) * ((if p.1 = p.2 then 1 else 0) * (if q.1 = q.2 then 1 else 0))

def rho (p : ℚ) : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℚ :=
  p • Phi + ((1-p)/4) • (1 : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℚ)

def pt (X : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℚ) : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℚ :=
  Matrix.of fun a b => X (a.1, b.2) (b.1, a.2)

def charAt (X : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℚ) (l : ℚ) : ℚ :=
  (X - l • (1 : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℚ)).det

def S : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℚ :=
  Matrix.of fun a b => if a.1 = b.2 ∧ a.2 = b.1 then 1 else 0

#eval (Phi.trace, (rho 1).trace, (rho (1/2)).trace)
#eval (charAt (pt (rho 1)) ((1+1)/4), charAt (pt (rho 1)) ((1-3)/4))
#eval (charAt (pt (rho (1/2))) ((1/2+1)/4), charAt (pt (rho (1/2))) ((1-3/2)/4))
#eval (charAt (pt (rho (1/3))) ((1/3+1)/4), charAt (pt (rho (1/3))) ((1-1)/4))
#eval ((pt (rho (1/2)) * pt (rho (1/2))).trace, (rho (1/2) * rho (1/2)).trace)
#eval ((pt (rho 1) * pt (rho 1)).trace, (rho 1 * rho 1).trace)
#eval (decide (S * S = 1), S.trace, decide (pt (rho 1) = (1/2 : ℚ) • S))
#eval (3*((1:ℚ)+1)/4 + |(1-3*(1:ℚ))/4|, 3*((1/2:ℚ)+1)/4 + |(1-3*(1/2:ℚ))/4|,
       3*((1/3:ℚ)+1)/4 + |(1-3*(1/3:ℚ))/4|)
#eval (charAt (pt (rho (2/3))) ((2/3+1)/4), charAt (pt (rho (2/3))) ((1-2)/4),
       3*((2/3:ℚ)+1)/4 + |(1-3*(2/3:ℚ))/4|)
```

Output (verbatim):

```
(1, 1, 1)
(0, 0)
(0, 0)
(0, 0)
(7 / 16, 7 / 16)
(1, 1)
(true, 2, true)
(2, 5 / 4, 1)
(0, 0, 3 / 2)
```

**Status of this evidence.** These `#eval` computations are exact rational computations, but
they are *evidence*, not proof; every claim they support is separately proved, sorry-free, in
`Catalog/Physics/EntanglementMonotone/`.
