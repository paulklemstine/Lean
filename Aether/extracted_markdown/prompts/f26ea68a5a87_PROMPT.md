Produce exactly one new Lean file in the cryptography domain, for example `Catalog/Cryptography/OneTimePadPerfectSecrecy.lean`. The file must formalize the one-time-pad counting argument over an arbitrary finite group and must contain only the OTP material described below.

Requirements:
1. Import only what is needed from Mathlib.
2. Use a namespace appropriate to the file.
3. Assume `G : Type*` with `[Group G] [Fintype G] [DecidableEq G]`.
4. Prove exactly these three theorems with complete proof bodies and no `sorry`:

`otp_unique_key : ∀ (m c : G), ∃! k : G, k * m = c`
Proof idea: the unique key is `c * m⁻¹`; verify existence by group cancellation and uniqueness by multiplying on the right by `m⁻¹`.

`otp_key_fiber_card : ∀ (m c : G), Fintype.card {k : G // k * m = c} = 1`
Proof idea: use `otp_unique_key` to show the subtype of valid keys is a singleton up to equivalence, then conclude its `Fintype.card` is `1`. You may use `Fintype.card_subtype_iff_unique` or build a `Unique` instance for the subtype if convenient.

`otp_perfect_secrecy_count : ∀ (m1 m2 c : G), Fintype.card {k : G // k * m1 = c} = Fintype.card {k : G // k * m2 = c}`
Proof idea: both sides are `1` by `otp_key_fiber_card`.

5. Do not include any unrelated definitions, examples, comments about other domains, or extra theorem families.
6. Do not switch to number theory, algebraic reductions, or any topic outside OTP perfect secrecy.
7. If a theorem statement as written needs implicit parameters moved to theorem binders, do so in the standard Lean style, but keep the mathematical content exactly the same.
8. Prefer subtype cardinality (`{k : G // ...}`) over any malformed `Finset`-of-elements encoding.

The file should be clean, minimal, and compile as a standalone formalization of the counting proof of perfect secrecy for the one-time pad over finite groups.