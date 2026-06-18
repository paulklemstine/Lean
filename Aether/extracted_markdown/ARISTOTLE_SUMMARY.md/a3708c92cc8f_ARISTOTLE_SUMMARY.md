# Summary of changes for run ac43dd4e-f08f-437f-933f-61a7fe5142e7
Formalized narcissistic (Armstrong) numbers in Lean 4 and proved their finiteness, in the new file `Computation/Narcissistic.lean`.

What was done:
- **Definition** `IsNarcissistic n`: `n` equals the sum of its decimal digits each raised to the power of the number of digits. The prompt's literal `(Nat.digits 10 n).sum fun d => ...` does not elaborate (`List.sum` takes no function argument), so I expressed the intended meaning faithfully as `n = ((Nat.digits 10 n).map fun d => d ^ (Nat.digits 10 n).length).sum`, with an explanatory note in the file's docstring.
- **Sum bound** `digit_pow_sum_le`: for any list of digits all `< 10`, the sum of their `L`-th powers is `≤ length * 9 ^ L`.
- **Key exponential inequality** `key_ineq`: for all `d ≥ 61`, `d * 9 ^ d < 10 ^ (d - 1)`, proved by induction from the base case `d = 61` with the monotonicity step `9·(d+1) ≤ 10·d`.
- **Main finiteness theorem** `narcissistic_lt`: every narcissistic number satisfies `n < 10 ^ 60`. Proof: a `d`-digit number is `≥ 10^(d-1)` but a narcissistic one is `≤ d·9^d`; for `d ≥ 61` these contradict via `key_ineq`, forcing `d ≤ 60`, hence `n < 10^d ≤ 10^60`.
- **Decidability**: a computable `Bool`-valued `isNarcissisticBool`, a proof `isNarcissisticBool_iff` that it agrees with `IsNarcissistic`, and a derived `DecidablePred IsNarcissistic` instance.
- **Specimens**: `1`–`9`, `153`, `370`, `371`, `407` all proved narcissistic (via `decide`).

Verification: the module builds successfully with no `sorry`. `#print axioms` shows the main results depend only on the standard axioms `propext`, `Classical.choice`, `Quot.sound` (fully kernel-checked, no `native_decide`).