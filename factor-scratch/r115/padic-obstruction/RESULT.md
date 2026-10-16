# Axis F (round 115): the p-adic obstruction

**Files**

| file | what |
|---|---|
| `PadicTorsionObstruction.lean` | one self-contained Lean 4 file (`import Mathlib` only, no catalog imports), namespace `PadicTorsionObstruction` |
| `build.log` | verbatim, unedited output of the reproduce command below (two runs, identical md5) |

**Toolchain:** Lean `v4.28.0` (`leanprover/lean4:v4.28.0`, Lake 5.0.0), Mathlib v4.28.0,
prebuilt oleans from `/home/raver1975/lean/Catalog`.

---

## 1. The claim

The Smart / Satoh–Araki–Semaev attack solves ECDLP in polynomial time on **anomalous** curves
(`#E(F_p) = p + 1 − t = p`). The tempting generalisation is small-nonzero-trace curves. It does
not exist: a **torsion obstruction** forbids it. Precisely, this file proves:

**(T1)** If `A` is additively torsion-free, every additive group homomorphism `f : G →+ A`
kills every element of finite order.

**(T3)** If `G` is finite with `Fintype.card G` coprime to `p` and `A` is additively
torsion-free, the only homomorphism `G →+ A` is `0`. Since `#E(F_p) = p + 1 − t` with `t ≠ 1`
is coprime to `p`, this is the statement that kills the generalisation.

**(T2′)** The sharp form: only torsion-freeness at the primes that actually divide the order of
the element is needed.

**(T2 as literally briefed — REFUTED.)** The brief's T2 — *"`A` has no `p`-torsion in the sense
`(∀ a : A, p • a = 0 → a = 0)` and `x : G` has order prime to `p` implies `f x = 0`"* — is
**false**. Counterexample proved in the file: `p = 3`, `G = A = ZMod 2`, `x = 1`, `f = id`.
`ZMod 2` has no `3`-torsion (`3 • a = a`), `addOrderOf 1 = 2` is coprime to `3`, and
`f 1 = 1 ≠ 0`. "No `p`-torsion" does **not** imply "no `q`-torsion for `q ≠ p`", so it does not
imply "torsion-free". T2′ is the repaired statement; it needs `A` to be `q`-torsion-free for
every prime `q ∣ n` (`n` the annihilator), which is what a pro-`p` group such as `p·ℤ_p ⊆ ℚ_p`
has and what full torsion-freeness gives.

**Verdict: SUPPORTED.** T1, T2′ and T3 are proved; T2 as written is refuted with a
machine-checked counterexample. Because a rigourous kill is a success, the refutation of the
over-strong T2 is reported as a *result*, not buried: the axis's headline theorem survives, the
brief's auxiliary lemma did not.

---

## 2. The exact Lean statements proved

```lean
-- T1: the torsion obstruction (additive statement)
theorem hom_from_finOrder_to_IsAddTorsionFree_eq_zero
    {G : Type*} [AddCommGroup G] {A : Type*} [AddCommGroup A] [IsAddTorsionFree A]
    (f : G →+ A) (x : G) (hx : IsOfFinAddOrder x) : f x = 0

-- T1 with the brief's literal `IsOfFinOrder` hypothesis, transported through `Additive`
theorem hom_from_finOrder_to_IsAddTorsionFree_eq_zero_mul
    {G : Type*} [CommGroup G] {A : Type*} [AddCommGroup A] [IsAddTorsionFree A]
    (f : Additive G →+ A) (x : G) (hx : IsOfFinOrder x) :
    f (Additive.ofMul x) = 0

-- T1 in "annihilated by n ≠ 0" form (what the finite-group version needs)
theorem map_eq_zero_of_nsmul_eq_zero
    {G : Type*} [AddCommGroup G] {A : Type*} [AddCommGroup A] [IsAddTorsionFree A]
    (f : G →+ A) (x : G) {n : ℕ} (hn : n ≠ 0) (hx : n • x = 0) : f x = 0

-- Core lemma behind T2′
theorem eq_zero_of_nsmul_eq_zero_of_torsionFree_at_primes
    {A : Type*} [AddCommGroup A] {n : ℕ} (hn : n ≠ 0)
    (hA : ∀ q, Nat.Prime q → q ∣ n → (∀ a : A, q • a = 0 → a = 0))
    (z : A) (hz : n • z = 0) : z = 0

-- T2′ — the repaired ECDSA shape
theorem map_eq_zero_of_finOrder_and_coprime
    {G : Type*} [AddCommGroup G] {A : Type*} [AddCommGroup A]
    (p : ℕ) (hA : ∀ q, Nat.Prime q → q ≠ p → (∀ a : A, q • a = 0 → a = 0))
    (f : G →+ A) (x : G) (hx : IsOfFinAddOrder x) (hcp : Nat.Coprime p (addOrderOf x)) :
    f x = 0

-- T2′ without the IsOfFinAddOrder witness
theorem map_eq_zero_of_coprime_period
    {G : Type*} [AddCommGroup G] {A : Type*} [AddCommGroup A]
    (p : ℕ) (hA : ∀ q, Nat.Prime q → q ≠ p → (∀ a : A, q • a = 0 → a = 0))
    (f : G →+ A) (x : G) {n : ℕ} (hn : n ≠ 0) (hx : n • x = 0) (hcp : Nat.Coprime p n) :
    f x = 0

-- T3 (sharp form)
theorem hom_eq_zero_of_coprime_card
    {G : Type*} [AddCommGroup G] [Fintype G] {A : Type*} [AddCommGroup A]
    (p : ℕ) (hA : ∀ q, Nat.Prime q → q ≠ p → (∀ a : A, q • a = 0 → a = 0))
    (hcp : Nat.Coprime p (Fintype.card G)) (f : G →+ A) : f = 0

-- T3 for a torsion-free target
theorem hom_eq_zero_of_coprime_card_torsionFree
    {G : Type*} [AddCommGroup G] [Fintype G] {A : Type*} [AddCommGroup A] [IsAddTorsionFree A]
    (p : ℕ) (hcp : Nat.Coprime p (Fintype.card G)) (f : G →+ A) : f = 0

-- the arithmetic bridge #E = p + 1 - t
theorem card_coprime_of_trace_ne_one (p t : ℕ) (hp : Nat.Prime p) (ht : 2 ≤ t) (ht2 : t < p) :
    Nat.Coprime p (p + 1 - t)
theorem p_divides_card_iff_trace_eq_one (p t : ℕ) (hp : Nat.Prime p) (ht : 1 ≤ t)
    (ht2 : t < p) : p ∣ p + 1 - t ↔ t = 1

-- the ECDSA shape
theorem only_zero_hom_of_curve_order
    {G : Type*} [AddCommGroup G] [Fintype G] {A : Type*} [AddCommGroup A] [IsAddTorsionFree A]
    (p t : ℕ) (hp : Nat.Prime p) (ht : 2 ≤ t) (ht2 : t < p)
    (hcard : Fintype.card G = p + 1 - t) (f : G →+ A) : f = 0

-- the refutation of the brief's literal T2
theorem brief_T2_is_false :
    ¬ (∀ (p : ℕ) (G : Type) [AddCommGroup G] (A : Type) [AddCommGroup A],
        (∀ a : A, p • a = 0 → a = 0) →
        ∀ x : G, Nat.Coprime p (addOrderOf x) → ∀ f : G →+ A, f x = 0)

-- positive controls
theorem nonzero_hom_ZMod4_self : ∃ f : ZMod 4 →+ ZMod 4, f 1 ≠ 0
theorem nonzero_hom_ZMod4_ZMod2 : ∃ f : ZMod 4 →+ ZMod 2, f 1 ≠ 0
theorem hom_ZMod4_rat_eq_zero (f : ZMod 4 →+ ℚ) (x : ZMod 4) : f x = 0
theorem hom_ZMod4_rat_eq_zero_via_sharp (f : ZMod 4 →+ ℚ) : f = 0
theorem addOrderOf_one_zmod4 : addOrderOf (1 : ZMod 4) = 4 := ZMod.addOrderOf_one 4
theorem addOrderOf_one_zmod2 : addOrderOf (1 : ZMod 2) = 2 := ZMod.addOrderOf_one 2
```

**Verification level.** `#print axioms` on every one of the theorems above returns only
`[propext, Classical.choice, Quot.sound]` — the standard Mathlib axioms. There is **no**
`sorryAx`, no `axiom` declaration, no `native_decide`, no `decide`-black-box on any theorem
(the only `decide` uses are the `ZMod 2` / `ZMod 4` / `Nat.Coprime` sanity checks and the
`#eval` block, which are allowed). grep for `sorry|axiom|native_decide|admit|unsafe` in the
file returns nothing.

---

## 3. The falsifier — what a reader should check

The claim is **SUPPORTED** if the reader reproduces a zero-error build. It is **REFUTED** if
any of the following holds:

1. **The main theorem fails to build**, or builds but depends on `sorryAx`.
2. **`brief_T2_is_false` does not build.** That theorem *is* a counterexample; if it does not
   type-check, the refutation of the brief's T2 does not stand.
3. **A reviewer finds the arithmetic bridge wrong.** `p_divides_card_iff_trace_eq_one` says
   that for prime `p` with `1 ≤ t < p`, `p ∣ p + 1 − t ↔ t = 1`. Check it against the
   `#eval` table: `p = 7` gives `gcd 7 6 = 1` (t=2), `gcd 7 7 = 7` (t=1), `gcd 7 8 = 1` (t=0).
   If those disagree with the convention you use (some authors write `t = #E − p − 1`, some
   absorb the `+1`), the statement needs re-indexing; the group-theoretic T1/T2′/T3 do not
   depend on it.
4. **A reviewer objects that `IsOfFinAddOrder` is not `IsOfFinOrder`.** It is not, and that is
   a real Lean-level finding, not a dodge — see `hom_from_finOrder_to_IsAddTorsionFree_eq_zero_mul`
   for the `Additive`-transported version with the literal `IsOfFinOrder x`. Details in §5.
5. **The most important check for the campaign:** T1/T3 are statements about *abstract groups*.
   A reader should ask whether they actually say anything about elliptic curves. They say
   something only under the hypothesis that the p-adic logarithm is a group homomorphism with a
   torsion-free target. That hypothesis is *not* proved here — see §4.

---

## 4. How far T1–T3 get toward the ECDSA statement, and what is NOT formalised

**Honest assessment of the gap.** This is the part that matters most, so it is stated bluntly.

What is proved, machine-checked: a *universal obstruction*. If `f : G →+ A` is a group
homomorphism, `G` a finite abelian group, `A` additively torsion-free, and `p ∤ |G|`, then
`f = 0`. Chaining `p ∤ |G|` with `|G| = p + 1 − t` for `t ≠ 1` gives: **no group homomorphism
from such an `E(F_p)` into any additively torsion-free group exists.**

What is **not** proved, and cannot be with Mathlib v4.28:

1. **Elliptic curves do not exist in this file.** There is no `E`, no `F_p`-points type, no
   group law, no `#E`. The theorem is `∀ (G : Type) [AddCommGroup G] [Fintype G] ...` — a
   *hypothesis slot* named `G` and a *hypothesis* `Fintype.card G = p + 1 - t`. Filling the slot
   with a real `E(F_p)` requires the whole algebraic-geometry stack (Weierstrass models, point
   counting, Hasse), which Mathlib does not have. `only_zero_hom_of_curve_order` is therefore
   best read as a **schema**, not as a theorem about curves.
2. **The formal group is not defined, so the actual attack is not modelled.** The Smart/SAS map
   is not "any homomorphism"; it is a specific isomorphism between `E(F_p)`'s reduction of its
   formal group and `p·ℤ_p`. Proving it is a homomorphism on anomalous curves requires the
   formal group `Ĝ` of `E` at `O`, the fact that the reduction map `E(F_p) → Ĝ(p·F_p/F_p^2)`
   is a group homomorphism for supersingular curves, and the logarithm `log : Ĝ(… ) → ℚ_p`.
   None of that is in Mathlib. The formalisation shows the trick is *blocked in principle* on
   any group homomorphism into a torsion-free target; it does not show the trick *works* on
   anomalous curves.
3. **The ordinary/supersingular distinction is absent**, and with it the content of the brief's
   parenthetical that anomalous curves work "precisely because they are supersingular, formal
   group of height 2, which DOES contain p-torsion". This is a statement about the structure of
   `E[p]` and of the formal group; the height-2 formal group `Ĝ ≅ Ẑ_p × Ẑ_p` (up to a unit)
   genuinely does have a `p`-power-torsion subgroup, unlike the height-1 (ordinary) one which is
   isomorphic to the formal additive group `Ẑ_p` and is torsion-free. Formalising "the formal
   group of an ordinary curve is torsion-free" needs the theory of formal group laws over a
   DVR, again absent.
4. **`p·ℤ_p ⊆ ℚ_p` is not in Mathlib v4.28** (no `PadicInt`), so the actual target group of the
   attack cannot be instantiated. `ℚ` is used as a stand-in for "some additively torsion-free
   group", which is legitimate for the *obstruction* (it is universal in `A`) but means the
   statement "no hom `E(F_p) → p·ℤ_p` exists" is derived as: `p·ℤ_p` is a subgroup of `ℚ_p`,
   `ℚ_p` is torsion-free, hence `p·ℤ_p` is torsion-free — and that last step is *not*
   machine-checked here (it is a two-line argument, but it is not in this file).

So: **T1/T3 get the campaign a machine-checked, assumption-explicit, universal obstruction
theorem.** They do not, by themselves, close Axis F as a *cryptanalytic* statement. The honest
status of Axis F remains: **CLOSED as mathematics (the obstruction is a standard fact, now
formalised), OPEN as a formalisation** — specifically, a formalisation that actually mentions
`E(F_p)` and the formal group would be a different, much larger project (Weierstrass models +
formal group laws), which no existing Lean library supports.

Also worth flagging: the obstruction argument is **not** what practitioners cite when they say
the `t ≠ 0` generalisation fails; the standard account is that the `p`-adic log is defined on
`1 + p·ℤ_p` (or on the formal group) and that lifting a point of `E(F_p)` into that domain
fails at nonzero trace because the lift lands in the kernel. The T1/T3 argument is a
**sharper, coarser** statement: it rules out *every* homomorphism, not just the specific
logarithm. Overlapping content, smaller footprint.

---

## 5. Two Lean-level findings worth recording

### 5.1 The brief's `[AddCommGroup G] ... (hx : IsOfFinOrder x)` cannot be elaborated

Lean 4.28 / Mathlib v4.28 has **no `Monoid` instance on an `AddMonoid`** (Mathlib avoids the
`AddMonoid`/`Monoid` diamond), so `IsOfFinOrder x` with `x` in an `AddCommGroup` fails to
elaborate:

```
error: failed to synthesize instance of type class Monoid G
```

The additive counterpart is `IsOfFinAddOrder` (the `@[to_additive]` form of `IsOfFinOrder`:
`AddMonoid.addOrderOf_eq_one_iff`, `IsOfFinAddOrder.exists_nsmul_eq_zero`, …). The main T1 in
this file is stated with `IsOfFinAddOrder`, and
`hom_from_finOrder_to_IsAddTorsionFree_eq_zero_mul` gives the brief's literal hypothesis via
the `Additive`/`Multiplicative` transport (`isOfFinAddOrder_ofMul_iff`). Anyone re-using the
brief's exact statement will hit this.

### 5.2 `addOrderOf` is `noncomputable`, so `orderOf` values cannot be `#eval`ed

`#eval orderOf (1 : ZMod 4)` fails with `dependsOnNoncomputable`. The positive control
therefore computes the orders with a self-written brute-force helper `zmodOrder` (which IS
`#eval`-able, `4 1 ↦ 4`, `4 2 ↦ 2`, `4 3 ↦ 4`, `4 0 ↦ 1`, `2 1 ↦ 2`) and proves the
`addOrderOf` values as theorems (`ZMod.addOrderOf_one`), noting the discrepancy. This is a
genuine restriction, not a choice.

### 5.3 The brief's `t = 0 ⇒ #E = p` is off by one

With `#E = p + 1 − t`, the anomalous case is `t = 1` (then `#E = p`), not `t = 0`
(then `#E = p + 1`, already coprime to `p`). `p_divides_card_iff_trace_eq_one` pins this down.
The *mathematical* content of Axis F is unaffected (the relevant condition is "`p ∤ #E`",
i.e. `t ≢ 1 mod p`, and by Hasse `|t| ≤ 2√p < p` for `p > 4` that is exactly `t ≠ 1`), but any
write-up that says "`t = 0` ⇒ `#E = p`" is wrong and should be fixed before it propagates.

---

## 6. Deduplication

`/home/raver1975/lean/Catalog/Cryptography/Factoring/PadicFactoring.lean` exists and was read
in full. **It is not about this obstruction.** It formalizes a *different* (and false) claim:
that every `n > 1` has a nontrivial factorization, and its two theorems are

```lean
theorem pAdic_factoring_oracle_false :
    ¬ (∀ (p : ℕ) [Fact p.Prime] (n : ℕ), n > 1 →
      ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1)
theorem pAdic_factoring_oracle_corrected {p : ℕ} [Fact p.Prime] (n : ℕ) (hn : n > 1)
    (hc : ¬ Nat.Prime n) :
    ∃ a b : ℕ, a * b = n ∧ a > 1 ∧ b > 1
```

No group theory, no torsion, no `IsAddTorsionFree`, no `AddMonoidHom`, no elliptic curves; the
only shared word with this deliverable is "p-adic" in the title. Nothing to reuse, nothing to
conflict with. This deliverable therefore uses the new name `PadicTorsionObstruction.lean`, as
instructed, and lives outside `Catalog/`.

`Catalog/Cryptography/PairingCryptanalysis.lean` was read for house style (module docstring,
`import Mathlib` first, one namespace, docstrings on every theorem, `#eval` sanity checks
alongside proofs).

---

## 7. Reproduce

```
cd /home/raver1975/lean/Catalog && lake env lean \
  /home/raver1975/lean/factor-scratch/r115/padic-obstruction/PadicTorsionObstruction.lean
```

Run twice (campaign rule: run every count twice). Both runs of this command produced
**identical output** (md5 `3a3275f6afc5f8f5fbfd959f3abac8c1`, saved in `build.log`) and
**exit status 0**, with zero errors, zero warnings, and the `#print axioms` block reporting
`[propext, Classical.choice, Quot.sound]` only for all 16 theorems. No `lake build` was run
(another job is using the CPU), and nothing was committed.

---

## 8. Positive-control block (campaign rule: never publish a null without one)

The hypotheses of T1 are exercised, not vacuous:

| control | outcome |
|---|---|
| `∃ f : ZMod 4 →+ ZMod 4, f 1 ≠ 0` | **true** (`AddMonoidHom.id`) — T1's conclusion genuinely fails when `IsAddTorsionFree A` is dropped |
| `∀ f : ZMod 4 →+ ℚ, ∀ x, f x = 0` | **true**, by T1 (`ℚ` torsion-free, `4 • x = 0`) |
| `∃ f : ZMod 4 →+ ZMod 2, f 1 ≠ 0` | **true** (`ZMod.castHom`) — and here `Nat.Coprime 2 4` is *false*, so T3's coprimality hypothesis is needed |
| `∀ f : ZMod 4 →+ ℚ, f = 0` via T2′ with `p = 3` | **true** — the sharp route also reproduces the control |
| `addOrderOf (1 : ZMod 4) = 4`, `addOrderOf (1 : ZMod 2) = 2` | proved as theorems |
| `#eval zmodOrder 4 1 / 4 2 / 4 3 / 4 0 / 2 1` | `4 / 2 / 4 / 1 / 2`, matching those theorems |
| `#eval 3 • (1 : ZMod 2)` | `1` (nonzero) — the witness that refutes the brief's T2 |
| `#eval (decide (Nat.Coprime 3 4), decide (Nat.Coprime 2 4))` | `(true, false)` |
| `#eval` gcd table `p = 7` | `t = 2 → (6, 1, true)`, `t = 1 → (7, 7, false)`, `t = 0 → (8, 1, true)` |
| `#eval` gcd table `p = 11` | `t = 2 → (10, 1, true)`, `t = 1 → (11, 11, false)` |

The `#eval` for `t = 1` printing `false` is the machine-readable form of "`p ∣ #E`", i.e. the
anomalous case, which is exactly the case the Smart/SAS attack needs and the only one the
obstruction does not cover.

---

## 9. Verdict

**SUPPORTED** (Axis F, T1 + T2′ + T3), with one sub-claim of the brief **REFUTED**
(the literal T2, counterexample `ZMod 2`).

* Proved: the universal torsion obstruction, its sharp form, and its finite-group corollary;
  the `#E = p + 1 − t` arithmetic bridge.
* Refuted: "`A` has no `p`-torsion and `x` has order prime to `p` ⇒ `f x = 0`".
* Not formalised, stated plainly in §4: elliptic curves, the formal group, the
  ordinary/supersingular (height 1 vs 2) distinction, `p·ℤ_p`, and the Smart/SAS map itself.
* No `sorry`, no `axiom`, no `native_decide`; build exit 0; reproducible byte-identically;
  nothing committed; no file outside `factor-scratch/r115/padic-obstruction/` touched.
