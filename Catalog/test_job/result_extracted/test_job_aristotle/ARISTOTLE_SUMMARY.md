# Summary of changes for run f027bb4b-3b7b-474c-b90a-519244dc17b7
Proved `tropical_firewall_determinism` in `Main.lean`. The proof uses `max_cases` to case-split on whether `max a b` equals `a` or `b` (and similarly for `max a c`), then `aesop` closes all cases. The key insight is that `a < max a b` forces `b > a`, so `max a b = b`; similarly `max a c = c`; then `b = c` follows from the hypothesis `max a b = max a c`.

The final proof is:
```lean
  cases max_cases a b <;> cases max_cases a c <;> aesop
```

I also fixed a minor lakefile version format issue (`"0.1"` → `"0.1.0"`) to allow the project to build.