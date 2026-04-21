/-! # CatalogBuild.Shared.P

Auto-generated from theorem catalog database.
Domain: Pythagorean/Berggren
Declarations: 1
-/

import Mathlib

/-- [Section: # Error Detection and Correction via Berggren Six-Tuples
This file formalizes the error detection capabilities of the Berggren six-tuple
(a, b, c, p, q, h) where (a,b,c) is a Pythagorean triple and (p,q,h) = M·(a,b,c).
The six components are stored independently. If any single component is perturbed,
the recovery equations detect the error.
## Main Results
1. **Recovery equations**: a, b, c can be recovered from p, q, h (and vice versa)
2. **Error detection**: Any single-component perturbation is detected
3. **Syndrome localization**: Different components produce different syndrome patterns
4. **Ghost Pythagorean preservation**: p²+q²=h² when a²+b²=c²] -/
def p (a b c : ℤ) : ℤ := a + 2*b - 2*c
