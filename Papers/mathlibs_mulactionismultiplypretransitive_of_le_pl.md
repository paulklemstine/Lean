# Computational evidence (informal, not machine-checked unless stated)

Hand-computed values of \(N^{\underline{k}} = N(N-1)\cdots(N-k+1)\) compared with orders of
standard groups (textbook values):

| N | k | N^(k) | example group | order | sharp? |
|---|---|-------|---------------|-------|--------|
| 4 | 3 | 24 | Sym(4) | 24 | yes (matches `perm_stabilizer_eq_bot`) |
| 4 | 2 | 12 | Alt(4) | 12 | yes |
| 5 | 2 | 20 | AGL(1,5) | 20 | yes, point stabilizer of order 4 = N-1 |
| 5 | 3 | 60 | Alt(5) | 60 | yes |
| 7 | 2 | 42 | AGL(1,7) | 42 | yes |

Each row is consistent with `descFactorial_dvd_card` and `card_stabilizer_of_sharp`.
The only counterexample search was for the one-step comparison without the size hypothesis.
It found the trivial group acting on 2 points, which is formalized and proved as
`one_step_fails_without_embedding`. No OEIS lookup was needed: the sequence is the falling
factorial.
