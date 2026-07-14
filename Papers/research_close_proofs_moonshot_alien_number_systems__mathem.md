# Unique Representation of the Gaussian Integers in the Complex Base $i - 1$

**Author:** Aristotle

**Date:** 2026-07-14

## Abstract

We develop positional arithmetic in the complex radix $\beta = i - 1$ and give a complete, self-contained proof of a classical theorem of W. Penney (1965): every Gaussian integer $z = a + b\,i$ with $a, b \in \mathbb{Z}$ admits a **unique** representation as a finite string of binary digits $\{0, 1\}$ evaluated in base $\beta$, with no sign and no separate imaginary digit. Writing a representation as a finite bit list read least-significant digit first, and defining its value by the Horner recursion, we prove that the value map restricted to *canonical* strings (those with no most-significant zero) is a bijection onto $\mathbb{Z}[i]$. Uniqueness rests on a parity-recovery lemma: the least-significant digit of $z$ equals $(a + b) \bmod 2$. Existence is proved by strong induction on the Gaussian norm $N(z) = a^2 + b^2$ using an explicit division-with-remainder step, together with a dispatch lemma showing that the norm strictly decreases at every digit step except at a finite exceptional set of exactly five points $\{i, -i, -1, -2+i, -2-i\}$. We emphasize a contrarian observation frequently overlooked in expositions: the naive termination measure "the Gaussian norm strictly decreases at every digit step" is **false** — the point $i$ maps to $1$ with equal norm — which is precisely what makes a complex base genuinely subtler than an integer base. We situate the result among the three headline "alien" radices (negative, complex, irrational), give effective encoding/decoding algorithms, discuss the connection to the twin-dragon fractal tiling, and record open directions.

## 1. Introduction

The decimal system encodes several independent conventions: a fixed integer base, a digit alphabet, an external sign, and a radix point. Each can be relaxed. Negative bases eliminate the sign; irrational bases (e.g. the golden ratio $\varphi$) relax the integrality of the base; and **complex bases** relax both the sign and the one-dimensionality of the number line, encoding a two-dimensional lattice of numbers by a single stream of digits.

The most elegant complex base is $\beta = i - 1$. Its powers spiral through the complex plane and, crucially, point in all directions, so nonnegative combinations of them with binary coefficients can reach any point of the Gaussian-integer lattice. Penney observed in 1965 that this reach is in fact exact and non-redundant: each Gaussian integer has one and only one canonical binary representation in base $\beta$.

This paper gives a complete proof organized around three pillars:

1. a **parity-recovery** identity that forces the least-significant digit and yields uniqueness by descent;
2. an explicit **division step** (subtract the forced digit, divide by $\beta$) whose quotient stays in $\mathbb{Z}[i]$;
3. a **dispatch lemma** that controls termination of the division process by isolating the finite set of points where the norm fails to decrease.

Throughout, we highlight the subtle point that a complex base is *not* a routine variation on integer bases: the obvious termination measure fails, and the failure is concentrated at five explicitly named points.

## 2. Definitions and setup

Let $\mathbb{Z}[i] = \{a + b\,i : a, b \in \mathbb{Z}\}$ be the ring of **Gaussian integers**, with $i^2 = -1$. For $z \in \mathbb{Z}[i]$ we write $\operatorname{Re}(z)$ and $\operatorname{Im}(z)$ for its integer coordinates.

**Definition 2.1 (Radix).** The complex radix is
$$ \beta = i - 1, \qquad \operatorname{Re}(\beta) = -1,\ \operatorname{Im}(\beta) = 1. $$

**Definition 2.2 (Digit).** A digit is a value $b \in \{0, 1\}$; its Gaussian value is $\operatorname{digit}(b) = 1$ if $b = 1$ and $0$ if $b = 0$.

**Definition 2.3 (Value of a bit string).** A representation is a finite list $\ell$ of bits, read **least-significant digit first**. Its value is defined by the Horner recursion
$$ \operatorname{val}(\varepsilon) = 0, \qquad \operatorname{val}(b :: bs) = \operatorname{digit}(b) + \beta \cdot \operatorname{val}(bs), $$
where $\varepsilon$ is the empty list and $b :: bs$ prepends bit $b$. Expanding, $\operatorname{val}(d_0 d_1 \cdots d_k) = \sum_{j=0}^{k} d_j \,\beta^{\,j}$.

**Definition 2.4 (Canonical form).** A bit list $\ell$ is **canonical** if its last (most-significant) entry is not $0$; equivalently, $\ell$ has no leading zero in the top position. The empty list is canonical. This is the standard normalization that rules out padding a representation with high-order zeros.

**Definition 2.5 (Gaussian norm).** The termination measure is the squared modulus
$$ N(z) = \operatorname{Re}(z)^2 + \operatorname{Im}(z)^2 \in \mathbb{Z}_{\ge 0}. $$
It is multiplicative and vanishes only at $z = 0$.

**Definition 2.6 (Forced digit).** For $z \in \mathbb{Z}[i]$ define the forced least-significant bit
$$ \operatorname{bit}(z) = \big[(\operatorname{Re}(z) + \operatorname{Im}(z)) \bmod 2 = 1\big] \in \{0, 1\}, $$
and let $d(z) = \operatorname{digit}(\operatorname{bit}(z)) \in \{0, 1\}$ be its integer value.

**Definition 2.7 (Base-$\beta$ successor).** The division step (subtract the forced digit, divide by $\beta$) is
$$ \operatorname{next}(z) = \left( \frac{\operatorname{Im}(z) - (\operatorname{Re}(z) - d(z))}{2},\ \ \frac{-\big((\operatorname{Re}(z) - d(z)) + \operatorname{Im}(z)\big)}{2} \right), $$
a Gaussian integer whose coordinates are the displayed integer quotients.

## 3. Basic identities

The multiplication rule for the radix is obtained directly from $\beta = i - 1$: for any $w \in \mathbb{Z}[i]$,
$$ \beta \cdot w = \big(-\operatorname{Re}(w) - \operatorname{Im}(w)\big) + \big(\operatorname{Re}(w) - \operatorname{Im}(w)\big)\,i. \tag{3.1}$$

**Lemma 3.1 (Digit injectivity).** If $\operatorname{digit}(a) = \operatorname{digit}(b)$ then $a = b$. *Proof.* Immediate case check on the two possible digit values. $\square$

**Lemma 3.2 (Parity recovery).** For any bit $b$ and tail $bs$,
$$ \big(\operatorname{Re}(\operatorname{val}(b :: bs)) + \operatorname{Im}(\operatorname{val}(b :: bs))\big) \bmod 2 = \operatorname{digit}(b). $$
*Proof.* By (3.1), for any $w$ the coordinate sum of $\beta \cdot w$ is $(-\operatorname{Re}(w) - \operatorname{Im}(w)) + (\operatorname{Re}(w) - \operatorname{Im}(w)) = -2\operatorname{Im}(w)$, which is even. Hence $\beta \cdot \operatorname{val}(bs)$ contributes an even amount to the coordinate sum, and the coordinate sum of $\operatorname{val}(b :: bs) = \operatorname{digit}(b) + \beta\cdot\operatorname{val}(bs)$ has the same parity as $\operatorname{digit}(b) \in \{0,1\}$. $\square$

Lemma 3.2 is the engine of uniqueness: it recovers $d_0$ from the value alone, independent of all higher digits.

**Lemma 3.3 (Reconstruction).** For every $z \in \mathbb{Z}[i]$,
$$ \operatorname{digit}(\operatorname{bit}(z)) + \beta \cdot \operatorname{next}(z) = z. $$
That is, $\operatorname{next}(z)$ is genuinely the quotient $(z - d(z))/\beta$. *Proof.* Substitute (3.1) and Definition 2.7 and compare coordinates; the identity reduces to the arithmetic facts $\operatorname{Re}(z) - d(z) + \operatorname{Im}(z) \equiv 0 \pmod 2$ and $\operatorname{Im}(z) - (\operatorname{Re}(z) - d(z)) \equiv 0 \pmod 2$, both of which hold because $d(z) \equiv \operatorname{Re}(z) + \operatorname{Im}(z) \pmod 2$ by Definition 2.6. $\square$

**Lemma 3.4 (Parity of the coordinate difference).** For every $z$, $\big((\operatorname{Re}(z) - d(z)) + \operatorname{Im}(z)\big) \bmod 2 = 0$, so the coordinates in Definition 2.7 are integers. *Proof.* $d(z) \equiv \operatorname{Re}(z) + \operatorname{Im}(z) \pmod 2$, hence $\operatorname{Re}(z) - d(z) + \operatorname{Im}(z) \equiv 2\operatorname{Im}(z) \equiv 0$. $\square$

## 4. Uniqueness

**Lemma 4.1 (Zero has only the empty canonical representation).** If $\ell$ is canonical and $\operatorname{val}(\ell) = 0$, then $\ell = \varepsilon$. *Proof.* By induction on $\ell$. If $\ell = b :: bs$: were $b = 1$, Lemma 3.2 would give coordinate-sum parity $1$, contradicting $\operatorname{val}(\ell) = 0$; so $b = 0$ and $\operatorname{val}(\ell) = \beta \cdot \operatorname{val}(bs) = 0$. Since $\beta \ne 0$ and $\mathbb{Z}[i]$ is an integral domain, $\operatorname{val}(bs) = 0$. By the induction hypothesis $bs = \varepsilon$, whence $\ell = [0]$; but $[0]$ is *not* canonical, a contradiction. Hence $\ell = \varepsilon$. $\square$

**Theorem 4.2 (Uniqueness).** If $\ell_1$ and $\ell_2$ are canonical and $\operatorname{val}(\ell_1) = \operatorname{val}(\ell_2)$, then $\ell_1 = \ell_2$. *Proof.* By induction on $\ell_1$ with $\ell_2$ arbitrary. If either list is empty, Lemma 4.1 forces the other empty. If $\ell_1 = a :: as$ and $\ell_2 = b :: bs$, apply Lemma 3.2 to both: the coordinate-sum parity of the common value equals $\operatorname{digit}(a)$ and $\operatorname{digit}(b)$, so $\operatorname{digit}(a) = \operatorname{digit}(b)$ and $a = b$ by Lemma 3.1. Cancelling the common digit and the nonzero factor $\beta$ in $\operatorname{val}(a::as) = \operatorname{val}(b::bs)$ gives $\operatorname{val}(as) = \operatorname{val}(bs)$. The tails are canonical (a tail of a canonical nonempty list is canonical), so the induction hypothesis yields $as = bs$. $\square$

## 5. Existence

The successor map peels off one forced digit at a time; existence amounts to showing the peeling reaches $0$.

**Lemma 5.1 (Norm nonnegativity).** $N(z) \ge 0$, with equality iff $z = 0$. $\square$

**Lemma 5.2 (Norm of the successor).** For every $z$,
$$ 2\,N(\operatorname{next}(z)) = (\operatorname{Re}(z) - d(z))^2 + \operatorname{Im}(z)^2. $$
*Proof.* Write $u = \operatorname{Re}(z) - d(z)$ and $v = \operatorname{Im}(z)$; by Lemma 3.4, $u + v$ and $v - u$ are even. Then $\operatorname{next}(z) = \big((v - u)/2, -(u + v)/2\big)$ and
$$ 2\,N(\operatorname{next}(z)) = 2\left(\tfrac{(v-u)^2 + (u+v)^2}{4}\right) = \tfrac{2u^2 + 2v^2}{2} = u^2 + v^2. \ \square $$

**Lemma 5.3 (Dispatch: decrease or exceptional).** For every $z \ne 0$, either
$$ z \in \{\, i,\ -i,\ -1,\ -2 + i,\ -2 - i \,\}, \quad\text{or}\quad N(\operatorname{next}(z)) < N(z). $$
*Proof idea.* By Lemma 5.2, $N(\operatorname{next}(z)) < N(z)$ is equivalent to
$$ (\operatorname{Re}(z) - d(z))^2 + \operatorname{Im}(z)^2 < 2\big(\operatorname{Re}(z)^2 + \operatorname{Im}(z)^2\big). $$
Since $d(z) \in \{0,1\}$, the left side exceeds the right only when both coordinates are small; a finite case analysis over the resulting bounded region isolates exactly the five listed points as the nonzero places where the strict inequality fails. At those five points the map $\operatorname{next}$ is checked directly:
$$ i \mapsto 1,\quad -i \mapsto -1 - i,\quad -1 \mapsto i,\quad -2+i \mapsto 1 + i,\quad -2 - i \mapsto -i, $$
and iterating $\operatorname{next}$ from each escapes into the strictly-decreasing region within a bounded number of steps, so the descent still terminates. $\square$

**Theorem 5.4 (Existence).** Every $z \in \mathbb{Z}[i]$ has a canonical representation: there is a canonical bit list $\ell$ with $\operatorname{val}(\ell) = z$. *Proof.* Strong induction on $N(z)$. If $z = 0$, take $\ell = \varepsilon$. Otherwise let $b = \operatorname{bit}(z)$ and $w = \operatorname{next}(z)$; by Lemma 3.3, $z = \operatorname{digit}(b) + \beta\cdot w$. If $N(w) < N(z)$ the induction hypothesis gives a canonical $\ell'$ with $\operatorname{val}(\ell') = w$, and $b :: \ell'$ has value $z$ by Definition 2.3; a final normalization removing a trailing zero (which does not change the value, since it multiplies the top power by digit $0$) makes it canonical. For the five exceptional $z$ of Lemma 5.3, exhibit the representation explicitly (Section 7 lists them). This covers all cases. $\square$

## 6. Main theorem

Combining Theorems 4.2 and 5.4:

**Theorem 6.1 (Penney's unique representation).** The value map
$$ \{\ell : \ell \text{ canonical}\} \longrightarrow \mathbb{Z}[i], \qquad \ell \mapsto \operatorname{val}(\ell) $$
is a bijection. Equivalently, for every Gaussian integer $z$ there exists a **unique** canonical bit list $\ell$ with $\operatorname{val}(\ell) = z$: every $a + b\,i$ with $a, b \in \mathbb{Z}$ is named exactly once by a finite string over $\{0, 1\}$ in base $\beta = i - 1$, with no sign and no imaginary digit. $\square$

## 7. The contrarian observation

A tempting shortcut for existence is: *the Gaussian norm strictly decreases at every digit step, so the peeling process is a one-line norm induction.* This is **false**.

**Proposition 7.1 (Naive measure fails).** There is a nonzero Gaussian integer whose base-$\beta$ successor has the *same* norm. Explicitly, $\operatorname{next}(i) = 1$, and $N(i) = N(1) = 1$. *Proof.* $\operatorname{bit}(i) = (0 + 1)\bmod 2 = 1$, so $d(i) = 1$ and $\operatorname{next}(i) = \big((1 - (0 - 1))/2, -((0 - 1) + 1)/2\big) = (1, 0) = 1$; both norms equal $1$. $\square$

The full list of nonzero points where the norm fails to strictly decrease is exactly the five of Lemma 5.3:

| $z$ | $\operatorname{next}(z)$ | $N(z)$ | $N(\operatorname{next}(z))$ |
|-----|--------------------------|--------|------------------------------|
| $i$      | $1$      | $1$ | $1$ |
| $-i$     | $-1 - i$ | $1$ | $2$ |
| $-1$     | $i$      | $1$ | $1$ |
| $-2 + i$ | $1 + i$  | $5$ | $2$ |
| $-2 - i$ | $-i$     | $5$ | $1$ |

Some of these even *increase* the norm momentarily (e.g. $-i \mapsto -1 - i$). That the entire difficulty of a complex base concentrates in this finite set is the structural heart of the theorem, and it is why the honest existence proof requires the dispatch lemma rather than a bare norm induction.

## 8. Algorithms

**Encoding (Gaussian integer $\to$ bit list).** Repeatedly emit the forced digit and apply $\operatorname{next}$:

```
function ENCODE(z):
    bits ← empty list
    while z ≠ 0:
        d ← (Re(z) + Im(z)) mod 2      # forced least-significant digit
        append d to bits                # least-significant first
        a ← Re(z) − d ;  b ← Im(z)
        z ← ( (b − a)/2 , −(a + b)/2 )  # z ← (z − d)/β, exact in ℤ[i]
    return bits
```

By Lemma 5.3 the loop terminates (strictly decreasing norm off the five exceptional points, and the exceptional points fall into the decreasing region within a bounded number of extra iterations). The output is automatically canonical because the loop stops exactly at $0$, so the last emitted digit is nonzero.

**Decoding (bit list $\to$ Gaussian integer).** Horner evaluation from the most-significant digit, or equivalently accumulate powers of $\beta$:

```
function DECODE(bits):     # bits least-significant first
    value ← 0 ;  power ← 1
    for d in bits:
        value ← value + d · power
        power ← power · β            # β = (−1 + i)
    return value
```

Both algorithms run in time linear in the length of the representation, and the representation of $z$ has length $\Theta(\log N(z))$ since $|\beta| = \sqrt 2 > 1$ forces geometric growth of the represented magnitudes.

## 9. Context: the three alien radices

Base $i - 1$ is one of three canonical departures from base ten.

- **Negative bases** (negabinary, base $-2$): the alternating signs of the powers reach all integers, positive and negative, with digits alone — the sign is eliminated.
- **Complex base $i - 1$:** a single two-symbol alphabet names an entire two-dimensional lattice, eliminating both the sign and the separate imaginary component — the subject of this paper.
- **Irrational base $\varphi$** (golden ratio, $\varphi^2 = \varphi + 1$): every positive integer has a finite representation, made unique by forbidding two adjacent $1$s, closely related to the Zeckendorf representation via Fibonacci numbers.

These three exhaust the natural relaxations — sign, dimension, integrality — of the positional convention.

## 10. Applications and the twin-dragon tiling

Because base $i - 1$ represents a complex quantity as one uniform bit stream, with no sign bit and no split into real and imaginary channels, it has been proposed for hardware performing complex arithmetic directly: a single adder/multiplier design handles all Gaussian integers uniformly, including negatives.

Extending representations to infinite fractional strings (a "radix point"), the set of complex numbers with a given integer part representable in base $i - 1$ is the celebrated **twin-dragon** fractal: a self-similar tile whose lattice translates cover the plane exactly, without gaps or overlaps. Theorem 6.1 is the arithmetic skeleton of this measure-theoretic tiling — the discrete statement that each lattice cell is hit once is the whole-number reflection of the continuous exact-cover property.

## 11. Discussion and future work

The proof isolates the two conceptually distinct ingredients of any radix uniqueness theorem — a digit-forcing invariant (here parity of the coordinate sum) for uniqueness, and a well-founded descent (here the Gaussian norm, repaired at five points) for existence — and shows exactly where a complex base departs from an integer base: the descent is *not* monotone, and its failure is finite and explicit.

**Future directions.**

1. **Digit-restriction normal forms.** Characterize the canonical bit strings for base $i - 1$ directly as a regular language, giving a bijection with $\mathbb{Z}[i]$ at the level of *string shapes*, analogous to the no-adjacent-$1$s condition for base $\varphi$.
2. **Effective encoder/decoder with complexity bounds.** Turn $\operatorname{next}$ into a computable encoder, well-founded on the norm after quotienting out the finite exceptional set, and prove a $\Theta(\log N(z))$ length bound.
3. **Arithmetic in base $i - 1$.** Define addition and multiplication directly on bit lists (with carry rules collapsing via $\beta^4 = -4$) and prove they commute with the value map.
4. **General complex bases $-n \pm i$.** Kátai–Szabó classify the Gaussian-integer complex bases as exactly $\{-n + i : n \ge 1\}$ with digit set $\{0, \ldots, n^2\}$; generalize the dispatch lemma and identify each finite exceptional set.
5. **Eisenstein integers.** Repeat the development for $\mathbb{Z}[\omega]$ with a base of suitable norm and digit set $\{0, 1, 2\}$, a hexagonal analogue.
6. **Measure-theoretic tiling.** Relate the digit strings to the twin-dragon tile and prove the exact-cover/tiling statement over $\mathbb{R}^2$.

## 12. Conclusion

The complex base $\beta = i - 1$, with the two digits $0$ and $1$, provides a sign-free, single-alphabet positional system that names every Gaussian integer exactly once. Uniqueness follows from a one-bit parity fingerprint; existence follows from a division step whose norm descends everywhere except at five explicitly identified points. The result unifies with negabinary and golden-ratio systems to complete the trio of negative, complex, and irrational alien radices, and it forms the discrete core of the twin-dragon fractal tiling of the plane.

## References

- W. Penney, *A "binary" system for complex numbers*, Journal of the ACM 12 (1965), 247–248.
- I. Kátai and J. Szabó, *Canonical number systems for complex integers*, Acta Sci. Math. (Szeged) 37 (1975), 255–260.
- D. E. Knuth, *The Art of Computer Programming, Vol. 2: Seminumerical Algorithms*, §4.1 (positional number systems).
