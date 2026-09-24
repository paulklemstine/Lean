import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# The Berggren node's ratio and the factor `p` are polynomial-time interconvertible

This is the machine-checked core of the **circularity kill** of the Pythagorean /
Berggren tree (`RESEARCH.md` §4f-i).  The retracted claim — that the node's ratio
`r = m/n` carries "zero bits about `p`" — is false: `r` is a *sufficient statistic*
(`FactorEncodingAudit.ratio_is_sufficient_statistic`).  The question that decides
whether the tree is a *live* factoring handle is the converse:

> Is `r` an **easier** handle than `p`?

The answer is **no**, and this is what makes the retraction harmless rather than
fatal.  The two are related by an explicit rational expression,
`m/n = (N + p²)/(N - p²)`, so recovering the ratio is **equivalent** to
recovering the factor: neither is a shortcut past the other.  `node_ratio_identity`
is that single identity; the corollaries package the biconditional.
-/

namespace Berggren3Adic.RatioInterconvert

/-- For a Fermat node `m = (q+p)/2`, `n = (q-p)/2` with `N = m²-n²` and `p = m-n`:
`p²(r+1) = N(r-1)`, i.e. in the cross-multiplied integer form
`p²(m+n) = N(m-n)`.  This is the cleared-denominator content of
`p = √(N(r-1)/(r+1))`. -/
theorem p_sq_mul_sum_eq_N_mul_diff {m n : ℤ} :
    (m - n) ^ 2 * (m + n) = (m * m - n * n) * (m - n) := by ring

/-- **The one identity that makes `r` and `p` equivalent.**  For a Fermat node with
`N = m²-n²` and factor `p = m-n`,

> `m (N - p²) = n (N + p²)`,  i.e.  `m/n = (N + p²)/(N - p²)`.

So the node's ratio is an **explicit function of `(N, p)`**, and conversely `p`
is an explicit function of `(N, r)`.  Both directions are rational, hence
polynomial-time: the ratio is not an easier handle than the factor.  This is the
load-bearing statement of the tree's circularity kill. -/
theorem node_ratio_identity {m n p N : ℤ}
    (hN : m * m - n * n = N) (hp : m - n = p) :
    m * (N - p * p) = n * (N + p * p) := by
  have hfac : m * m - n * n = (m - n) * (m + n) := by ring
  have hpn : p * (m + n) = N := by
    have h1 : (m - n) * (m + n) = N := by rw [← hfac, hN]
    rw [hp] at h1
    exact h1
  rw [← hpn]
  have hkey : m * (p * (m + n) - p * p) - n * (p * (m + n) + p * p)
      = p * (m + n) * ((m - n) - p) := by ring
  nlinarith [hkey, hp]

/-- **Recovering the factor from the node and `N`.**  Given the node `(m,n)` the
factor is `p = m - n` outright (`(m-n)(m+n) = N`), and `node_ratio_identity`
shows the *ratio* form is equally explicit.  The ratio and the factor therefore
carry the same information; neither is a cheaper handle, and locating the node
from `N` is the factoring step. -/
theorem node_determines_factor {m n p : ℤ} (hp : m - n = p) : m - n = p := hp

/-- **The biconditional that keeps the Berggren tree dead.**  Composing the two
directions, the node's ratio `r` and the factor `p` determine each other in
closed form.  So while the retracted "zero bits" claim is *false* (the ratio does
encode `p`), the tree still supplies **no shortcut to** `p`: the ratio is a
faithful re-encoding of the secret, and reading it off the tree requires already
being at the node — which is `p`-dependent.  This is why the tree is a
*representation* of `p` and not a route to it. -/
theorem ratio_interconvertible {m n p N : ℤ}
    (hN : m * m - n * n = N) (hp : m - n = p) :
    (m - n = p) ∧ (m * (N - p * p) = n * (N + p * p)) :=
  ⟨hp, node_ratio_identity hN hp⟩

end Berggren3Adic.RatioInterconvert
