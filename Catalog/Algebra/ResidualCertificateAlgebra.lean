import Mathlib

/-!
# The algebra of residual certificates

A *residual block* on a normed space is a map of the form `x ↦ x + r x` where the
*residual* `r` is `K`-Lipschitz; the number `K : ℝ≥0` is the block's **residual
certificate** and the resulting map is `(1 + K)`-Lipschitz.

This file isolates the purely algebraic layer of the theory: what happens to the
certificates when blocks are combined.

* **serial composition** multiplies gains, so the certificates combine by
  `serial a b = a + b + a * b`, i.e. `1 + serial a b = (1 + a) * (1 + b)`;
* **parallel composition** (the cartesian product with the max product norm)
  takes the maximum, `par a b = max a b`.

The two operations make `ℝ≥0` an idempotent commutative ordered structure: `serial`
is a commutative monoid law with unit `0`, `par` is an idempotent commutative monoid
law with unit `0`, and `serial` distributes over `par`.  The map `a ↦ 1 + a` is an
order isomorphism onto the "gains" `Set.Ici (1 : ℝ≥0)` carrying `(serial, par)` to
`(·*·, max)` — the positive part of the max-times tropical semiring.

The last section records the *laxity* of the certificate calculus: parallel-then-serial
certification is strictly coarser than serial-then-parallel certification, even though
the two describe the *same* map.  This is the algebraic shadow of the fact that the
certificate assignment is only a lax monoidal functor.

Main results:

* `ResidualCert.one_add_serial` — `1 + serial a b = (1 + a) * (1 + b)`;
* `ResidualCert.serial_par_distrib` — `serial` distributes over `par`;
* `ResidualCert.gainOrderIso` — `ℝ≥0 ≃o Set.Ici (1 : ℝ≥0)` via `a ↦ 1 + a`;
* `ResidualCert.gainHom` — the multiplicative embedding `(ℝ≥0, serial, 0) →* (ℝ≥0, *, 1)`;
* `ResidualCert.interchange_lax` and `ResidualCert.interchange_gap` — the interchange
  inequality and a witness that it is strict.
-/

namespace ResidualCert

open NNReal

/-- Certificate of a serial composition of two residual blocks:
`(1 + a) * (1 + b) = 1 + (a + b + a * b)`. -/
def serial (a b : ℝ≥0) : ℝ≥0 := a + b + a * b

/-- Certificate of a parallel composition of two residual blocks (max product norm). -/
def par (a b : ℝ≥0) : ℝ≥0 := max a b

/-- The *gain* of a certificate: the Lipschitz constant of the corresponding block. -/
def gain (a : ℝ≥0) : ℝ≥0 := 1 + a

@[simp] theorem gain_apply (a : ℝ≥0) : gain a = 1 + a := rfl

/-! ### Serial composition -/

theorem one_add_serial (a b : ℝ≥0) : 1 + serial a b = (1 + a) * (1 + b) := by
  simp only [serial]; ring

@[simp] theorem gain_serial (a b : ℝ≥0) : gain (serial a b) = gain a * gain b :=
  one_add_serial a b

theorem serial_comm (a b : ℝ≥0) : serial a b = serial b a := by
  simp only [serial]; ring

theorem serial_assoc (a b c : ℝ≥0) : serial (serial a b) c = serial a (serial b c) := by
  simp only [serial]; ring

@[simp] theorem serial_zero (a : ℝ≥0) : serial a 0 = a := by simp [serial]

@[simp] theorem zero_serial (a : ℝ≥0) : serial 0 a = a := by simp [serial]

theorem le_serial_left (a b : ℝ≥0) : a ≤ serial a b := by
  simp only [serial]
  exact le_add_right (le_add_right le_rfl)

theorem le_serial_right (a b : ℝ≥0) : b ≤ serial a b := by
  rw [serial_comm]; exact le_serial_left b a

/-- `serial` is monotone in both arguments. -/
theorem serial_mono {a b c d : ℝ≥0} (hab : a ≤ b) (hcd : c ≤ d) :
    serial a c ≤ serial b d := by
  simp only [serial]
  exact add_le_add (add_le_add hab hcd) (mul_le_mul' hab hcd)

/-- Serial composition is *strictly* monotone in the first argument. -/
theorem serial_lt_serial_left {a b c : ℝ≥0} (h : a < b) : serial a c < serial b c := by
  have : (1 : ℝ≥0) + serial a c < 1 + serial b c := by
    rw [one_add_serial, one_add_serial]
    have h1 : (0 : ℝ≥0) < 1 + c := by positivity
    exact mul_lt_mul_of_pos_right (by gcongr) h1
  exact lt_of_add_lt_add_left this

/-! ### Parallel composition -/

theorem par_comm (a b : ℝ≥0) : par a b = par b a := max_comm a b

theorem par_assoc (a b c : ℝ≥0) : par (par a b) c = par a (par b c) := max_assoc a b c

@[simp] theorem par_self (a : ℝ≥0) : par a a = a := max_self a

@[simp] theorem par_zero (a : ℝ≥0) : par a 0 = a := max_eq_left (zero_le a)

@[simp] theorem zero_par (a : ℝ≥0) : par 0 a = a := max_eq_right (zero_le a)

@[simp] theorem gain_par (a b : ℝ≥0) : gain (par a b) = max (gain a) (gain b) := by
  simpa [gain, par] using (max_add_add_left 1 a b).symm

/-- **Distributivity**: certifying a parallel pair and then composing serially agrees with
certifying the two serial compositions in parallel *when the second stage is shared*. -/
theorem serial_par_distrib (a b c : ℝ≥0) :
    serial (par a b) c = par (serial a c) (serial b c) := by
  rcases le_total a b with h | h
  · rw [par, max_eq_right h, par, max_eq_right (serial_mono h le_rfl)]
  · rw [par, max_eq_left h, par, max_eq_left (serial_mono h le_rfl)]

theorem par_serial_distrib (a b c : ℝ≥0) :
    serial c (par a b) = par (serial c a) (serial c b) := by
  rw [serial_comm, serial_par_distrib, serial_comm c a, serial_comm c b]

/-! ### The gain isomorphism onto the max-times semiring -/

/-- `a ↦ 1 + a` is an order isomorphism from certificates onto gains `[1, ∞)`. -/
def gainOrderIso : ℝ≥0 ≃o Set.Ici (1 : ℝ≥0) where
  toFun a := ⟨1 + a, by simp⟩
  invFun g := (g : ℝ≥0) - 1
  left_inv a := by simp
  right_inv g := Subtype.ext (add_tsub_cancel_of_le (Set.mem_Ici.mp g.2))
  map_rel_iff' := by
    intro a b
    simp

@[simp] theorem gainOrderIso_apply (a : ℝ≥0) : (gainOrderIso a : ℝ≥0) = 1 + a := rfl

/-- The gain map is injective: distinct certificates give distinct Lipschitz bounds. -/
theorem gain_injective : Function.Injective gain := fun a b h => by
  simpa [gain] using h

/-! ### The certificate monoid as an algebraic object -/

/-- The type of residual certificates, carrying the *serial* monoid structure. -/
def Cert : Type := ℝ≥0

/-- The certificate of a residual block, viewed in `Cert`. -/
def toCert (a : ℝ≥0) : Cert := a

/-- The underlying nonnegative real of a certificate. -/
def ofCert (a : Cert) : ℝ≥0 := a

instance : CommMonoid Cert where
  mul := serial
  one := (0 : ℝ≥0)
  mul_assoc := serial_assoc
  one_mul := zero_serial
  mul_one := serial_zero
  mul_comm := serial_comm

@[simp] theorem ofCert_mul (a b : Cert) : ofCert (a * b) = serial (ofCert a) (ofCert b) := rfl

@[simp] theorem ofCert_one : ofCert 1 = 0 := rfl

/-- **The certificate monoid is the multiplicative monoid of gains.**  `a ↦ 1 + a`
is an injective monoid homomorphism from `(Cert, ·)` to `(ℝ≥0, *)`. -/
def certGainHom : Cert →* ℝ≥0 where
  toFun a := gain (ofCert a)
  map_one' := by simp
  map_mul' a b := gain_serial (ofCert a) (ofCert b)

theorem certGainHom_injective : Function.Injective certGainHom := fun _ _ h =>
  gain_injective h

/-! ### Laxity of the interchange law -/

/-- **Interchange inequality.**  Certifying two serial compositions and then putting them
in parallel is at least as sharp as putting the stages in parallel first. -/
theorem interchange_lax (a b c d : ℝ≥0) :
    par (serial a c) (serial b d) ≤ serial (par a b) (par c d) :=
  max_le (serial_mono (le_max_left a b) (le_max_left c d))
    (serial_mono (le_max_right a b) (le_max_right c d))

/-- **The interchange inequality is strict**: with residual constants `0,1` in the first
stage and `1,0` in the second, the sharp certificate is `1` while the parallel-first
certificate is `3`.  Hence the certificate assignment is only *lax* monoidal. -/
theorem interchange_gap :
    par (serial 0 1) (serial 1 0) < serial (par 0 1) (par 1 0) := by
  norm_num [par, serial]

/-- Quantitative form of the gap: in gains, the sharp constant is `2` and the coarse one
is `4`. -/
theorem interchange_gap_gains :
    gain (par (serial 0 1) (serial 1 0)) = 2 ∧ gain (serial (par 0 1) (par 1 0)) = 4 := by
  constructor <;> norm_num [gain, par, serial]

/-- Equality holds in the interchange law whenever the two parallel branches share
the same second-stage certificate. -/
theorem interchange_eq_of_shared (a b c : ℝ≥0) :
    par (serial a c) (serial b c) = serial (par a b) (par c c) := by
  rw [par_self, serial_par_distrib]

end ResidualCert