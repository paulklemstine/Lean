import Applications.ActionSpectrum.LogConcavity
import Applications.ActionSpectrum.Shadow
import Applications.ActionSpectrum.Bridge

/-!
# Lab notebook: computing subset spectra

`SubsetSpectrum.spec` is executable, so all the experimental data quoted in the other files
of this directory can be recomputed here with `#eval`.  This file contains no theorems, only
the reproducible experiments behind the conjectures and counterexamples.

Recorded output (mathlib4 v4.28.0):

```
spectra of C_n on n points
  n = 3 : [1, 1, 1, 1]
  n = 4 : [1, 1, 2, 1, 1]
  n = 5 : [1, 1, 2, 2, 1, 1]
  n = 6 : [1, 1, 3, 4, 3, 1, 1]
  n = 7 : [1, 1, 3, 5, 5, 3, 1, 1]
  n = 8 : [1, 1, 4, 7, 10, 7, 4, 1, 1]
  n = 9 : [1, 1, 4, 10, 14, 14, 10, 4, 1, 1]
  n = 10: [1, 1, 5, 12, 22, 26, 22, 12, 5, 1, 1]

log-concavity defects  t_{r-1} t_{r+1} - t_r²  (positive = violation), r = 1 … n-1
  n = 6 : [2, -5, -7, -5, 2]
  n = 8 : [3, -9, -9, -51, -9, -9, 3]
  n = 10: [4, -13, -34, -172, -192, -172, -34, -13, 4]

slack in the shadow bound  r(n-r) t_r² - t_{r-1} t_{r+1}  (always ≥ 0, as proved)
  n = 6 : [2, 68, 135, 68, 2]
  n = 8 : [3, 185, 695, 1551, 695, 185, 3]
  n = 10: [4, 388, 2914, 11304, 16416, 11304, 2914, 388, 4]

S₄ on 4 points  : [1, 1, 1, 1, 1]
A₄ on 4 points  : [1, 1, 1, 1, 1]
A₅ on 5 points  : [1, 1, 1, 1, 1, 1]
Burnside check for C₄ at r = 2 : t₂·|G| = 8 = Σ_g #fixed 2-subsets = 8
```
-/

open SubsetSpectrum

/-- The spectrum of the regular action of `C_n`, as a list `t_0, …, t_n`. -/
def cyclicSpectrum (n : ℕ) [NeZero n] : List ℕ :=
  (List.range (n + 1)).map (fun r => spec (Cyc n) (ZMod n) r)

/-- The log-concavity defects `t_{r-1}·t_{r+1} - t_r²` of a spectrum (positive = violation). -/
def logConcavityDefect (l : List ℕ) : List ℤ :=
  (List.range (l.length - 2)).map (fun k =>
    (l.getD k 0 : ℤ) * (l.getD (k + 2) 0 : ℤ) - (l.getD (k + 1) 0 : ℤ) ^ 2)

/-- The slack `r(n-r)·t_r² - t_{r-1}·t_{r+1}` in the shadow bound. -/
def shadowSlack (n : ℕ) (l : List ℕ) : List ℤ :=
  (List.range (l.length - 2)).map (fun k =>
    (((k + 1) * (n - (k + 1)) : ℕ) : ℤ) * (l.getD (k + 1) 0 : ℤ) ^ 2
      - (l.getD k 0 : ℤ) * (l.getD (k + 2) 0 : ℤ))

#eval (cyclicSpectrum 3, cyclicSpectrum 4, cyclicSpectrum 5)
#eval (cyclicSpectrum 6, cyclicSpectrum 7)
#eval (cyclicSpectrum 8, cyclicSpectrum 9)
#eval cyclicSpectrum 10

#eval (logConcavityDefect (cyclicSpectrum 6), logConcavityDefect (cyclicSpectrum 8),
  logConcavityDefect (cyclicSpectrum 10))

#eval (shadowSlack 6 (cyclicSpectrum 6), shadowSlack 8 (cyclicSpectrum 8),
  shadowSlack 10 (cyclicSpectrum 10))

#eval (List.range 5).map (fun r => spec (Equiv.Perm (Fin 4)) (Fin 4) r)
#eval (List.range 5).map (fun r => spec (alternatingGroup (Fin 4)) (Fin 4) r)
#eval (List.range 6).map (fun r => spec (alternatingGroup (Fin 5)) (Fin 5) r)

#eval (spec (Cyc 4) (ZMod 4) 2 * Fintype.card (Cyc 4),
  ∑ g : Cyc 4, (((Finset.univ : Finset (ZMod 4)).powersetCard 2).filter
    (fun s => act (X := ZMod 4) g s = s)).card)