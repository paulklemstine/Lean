# The Music of the Hydrogen Atom

## A Ladder of Light

Strike a guitar string and it sings a single, pure note — plus a faint
shimmer of overtones stacked above it. The string cannot vibrate at just
*any* frequency; it is allowed only a discrete ladder of them, fixed by
the length of the string and the speed of waves along it. This is the
deepest idea in all of physics dressed in its simplest clothes:
**confinement produces quantization**. Pin a wave down at its ends and it
is forced to choose from a countable menu of shapes.

The hydrogen atom is the universe's purest instrument. It is a single
electron bound to a single proton, held in place not by the tension of a
string but by the electric pull between opposite charges. And just like
the guitar string, it can only "vibrate" — that is, exist — at a discrete
set of energies. When an electron drops from a higher rung of this energy
ladder to a lower one, it releases the difference as a single particle of
light, a photon. The colors of those photons are the atom's fingerprint.
They are the reason a hydrogen lamp glows a characteristic pinkish-red,
the reason we can read the chemical composition of stars a billion light
years away, and the reason quantum mechanics was invented at all.

This article tells the story of three precise mathematical facts about
that ladder: **what the rungs are**, **how many states sit on each rung**,
and **which jumps between rungs are allowed**. Each of these has now been
stated and proved with complete rigor, and together they reconstruct the
qualitative spectrum of hydrogen from pure mathematics.

## The Rungs: The Bohr Energies

In 1913, Niels Bohr wrote down a formula so simple it looks like it
cannot possibly be the secret of an atom. Measured in natural units
called Rydbergs, the allowed bound-state energies of hydrogen are

$$E_n = -\frac{1}{n^2}, \qquad n = 1, 2, 3, \dots$$

Here $n$ is the **principal quantum number**, an ordinary positive
integer. The ground state, the lowest and most stable configuration, is
$E_1 = -1$. Above it lie $E_2 = -\tfrac14$, $E_3 = -\tfrac19$,
$E_4 = -\tfrac{1}{16}$, and so on.

Several features of this little sequence carry deep physical meaning, and
each has been made into a theorem.

First, **every bound energy is negative**: $E_n < 0$ for all $n$. A
negative energy means the electron is *trapped* — it would take a positive
injection of energy to tear it free from the proton. This is the
mathematical signature of a bound state.

Second, **the ground state is exactly $-1$**, and **no state lies lower**:
$E_n \ge -1$ for every $n$, with equality only at $n = 1$. The atom has a
floor. The electron cannot spiral forever inward releasing infinite
energy — a catastrophe that classical physics actually predicted, and
which would have made matter impossible. Quantum mechanics installs a
hard lower bound, and that bound is the ground state.

Third, **the rungs climb steadily toward zero**. The sequence
$E_1 < E_2 < E_3 < \cdots$ is strictly increasing. Each successive level
sits higher than the last, ever closer to the ceiling at $E = 0$ but never
reaching it.

Fourth, and most beautifully, **the rungs pile up at the ceiling**. As
$n \to \infty$, $E_n = -1/n^2 \to 0$. The gaps between consecutive levels
shrink without limit; infinitely many rungs are crammed into the last
sliver of energy just below zero. The value $0$ is the **accumulation
point** of the entire discrete spectrum. It is where the bound states go
to die.

## The Ceiling and the Open Sky

What happens at $E = 0$ and above? Here the story changes character
completely. Give the electron *non-negative* energy and it is no longer
trapped: it can escape to infinity, ionizing the atom. These are the
**scattering states**, and crucially they are not quantized at all. Any
energy $E \ge 0$ is allowed. The spectrum above the ceiling is a solid,
continuous half-line.

Putting the two pieces together, the full spectrum of the hydrogen
Hamiltonian is

$$\sigma(H) = \left\{-\frac{1}{n^2} : n = 1, 2, 3, \dots\right\} \;\cup\; [0, \infty).$$

A discrete ladder of bound states accumulating at zero, fused to a
continuous open sky of free states. And the two pieces are **disjoint** —
a separately proved fact. No bound energy is also a scattering energy,
because every bound energy is strictly negative while every scattering
energy is non-negative. The negative numbers and the non-negative numbers
never meet. This clean separation is what lets physicists speak of "the
discrete spectrum" and "the continuous spectrum" as two distinct worlds
joined at a single seam, the **ionization threshold** at $E = 0$.

## The Colors: The Rydberg Formula

The whole point of a ladder is to climb up and down it. When an electron
falls from level $n$ to a lower level $m$ (so $m < n$), the energy it
sheds is carried off by a photon. That photon's energy is simply the
difference of two rungs:

$$E_{\text{photon}} = E_n - E_m = \left(-\frac{1}{n^2}\right) - \left(-\frac{1}{m^2}\right) = \frac{1}{m^2} - \frac{1}{n^2}.$$

This is the celebrated **Rydberg formula**, and the rearrangement above
is one of our theorems. Two further facts are proved about it. The photon
energy is always **positive** when $m < n$, as it must be — light carries
away energy, it does not absorb it from nothing. And because $1/n^2 > 0$,
every emission energy is strictly *less* than the series limit $1/m^2$,
the energy of the deepest possible plunge into level $m$ from infinitely
high up.

Set $m = 1$ and let $n$ run over $2, 3, 4, \dots$ and you generate the
**Lyman series**, hydrogen's ultraviolet fingerprint. Set $m = 2$ and you
get the **Balmer series** — the visible lines that paint the pink glow of
a hydrogen discharge tube and stripe the spectra of stars. These series
were measured in the laboratory decades before anyone understood why they
existed. The Rydberg formula was, for a generation, a magical numerical
coincidence. Bohr's energies explained it; this theorem makes that
explanation airtight.

## How Many States per Rung: Degeneracy

So far we have described the energy ladder as if each rung were a single
state. The truth is richer. Each principal level $n$ is actually a *bundle*
of distinct states that all happen to share the same energy. The number of
them is the **degeneracy** of the level, and it follows a strikingly
simple rule:

$$\text{degeneracy of level } n = n^2.$$

The ground state $n=1$ is solitary: $1^2 = 1$ state. Level $n=2$ holds
$2^2 = 4$ states; level $n=3$ holds $3^2 = 9$; and so on. Where do these
squares come from?

They come from the **shape** of the electron's wave, governed by a second
quantum number $\ell$, the **orbital** (or azimuthal) quantum number. For
a given $n$, the orbital number $\ell$ ranges over $0, 1, 2, \dots, n-1$.
Each value of $\ell$ defines a *subshell* — the familiar $s, p, d, f$
orbitals of chemistry. And each subshell of orbital number $\ell$ contains
exactly

$$2\ell + 1$$

distinct states, indexed by a third quantum number $m$, the **magnetic
quantum number**, which runs over the integers from $-\ell$ to $+\ell$.
Counting those integers — from $-\ell$ up to $\ell$ inclusive — gives
exactly $2\ell + 1$ of them, a fact proved directly.

Now add up the subshells. The total number of states on rung $n$ is

$$\sum_{\ell=0}^{n-1} (2\ell + 1) = 1 + 3 + 5 + \cdots + (2n-1) = n^2.$$

This is the ancient and gorgeous identity that **the sum of the first $n$
odd numbers is a perfect square** — the same fact the Greeks discovered by
arranging pebbles into square arrays. Here it governs the architecture of
the atom. The degeneracy of hydrogen is the figurate-number pattern of the
Pythagoreans, hiding inside quantum mechanics. The theorem proving
$\sum_{\ell=0}^{n-1}(2\ell+1) = n^2$ for *all* $n$ is a clean induction,
and it is the reason the periodic table has the shape it does.

## Why $m$ is "Magnetic": Angular Momentum

The magnetic quantum number earns its name from a physical operator. The
$z$-component of the electron's orbital angular momentum is, in the
language of wave mechanics, the differential operator

$$L_z = -i\,\frac{\partial}{\partial \varphi},$$

where $\varphi$ is the azimuthal angle — the angle of longitude as the
electron's wave wraps around the $z$-axis. The angular part of every
hydrogen wavefunction contains a factor

$$e^{i m \varphi},$$

a wave that winds around the axis $m$ times before closing up on itself.
Apply $L_z$ to this factor and something elegant happens. Differentiating
$e^{im\varphi}$ brings down a factor of $im$, and the $-i$ in front turns
$-i \cdot im = m$. The result is the **eigenvalue equation**

$$L_z\,e^{im\varphi} = m\,e^{im\varphi}.$$

The function comes back unchanged, scaled only by the integer $m$. In the
language of quantum mechanics, $e^{im\varphi}$ is an *eigenstate* of
$L_z$, and its measured angular momentum about the $z$-axis is exactly
$m$. This is why $m$ is the magnetic quantum number: it is literally the
amount of angular momentum the electron carries around the axis, and in a
magnetic field — which singles out a direction in space — states of
different $m$ split apart in energy. The derivative computation behind
this eigenvalue equation has been carried out rigorously, chain rule and
complex-exponential bookkeeping and all.

Why must $m$ be an *integer*? Because the wave must close up smoothly as
$\varphi$ goes once around the circle. The function $e^{im\varphi}$ is
unchanged when $\varphi$ increases by $2\pi$ — it is **$2\pi$-periodic** —
precisely when $m$ is a whole number. Periodicity quantizes angular
momentum, just as the fixed ends of a guitar string quantize its pitch.
The same theme, sounded again.

## Which Jumps Are Allowed: Selection Rules

Not every fall down the ladder is permitted. Quantum mechanics imposes
**selection rules** — strict bookkeeping conditions a transition must obey
to emit light. For the dominant kind of radiation, electric-dipole
emission, the rule is:

$$\Delta \ell = \pm 1 \qquad \text{and} \qquad \Delta m \in \{-1, 0, +1\}.$$

The orbital number must change by *exactly one*, and the magnetic number by
*at most one*. This single rule, encoded as a precise predicate, has
several consequences that have each been proved.

A transition that leaves $\ell$ unchanged is **forbidden**. In particular
the deceptively simple $s \to s$ jump ($\ell = 0 \to \ell = 0$) cannot
happen by dipole radiation at all — there is no way to satisfy
$\Delta\ell = \pm 1$ while keeping $\ell$ fixed at zero.

Every allowed transition **flips the parity** of the orbital. Parity is
the behavior of the wavefunction under reflection through the origin, and
it is governed by $(-1)^\ell$. The condition $\Delta\ell = \pm 1$ is
exactly the statement that $\ell + \ell'$ is **odd**, so the parity sign
must change between the initial and final states. This is no accident:
the photon itself is a spin-1 particle carrying one unit of angular
momentum and odd intrinsic parity. The selection rule is the atom's books
balancing — angular momentum and parity must be conserved, and the photon
is the bookkeeper that carries away the difference.

The rule is also **symmetric**: a transition $(\ell, m) \to (\ell', m')$
is allowed if and only if the reverse $(\ell', m') \to (\ell, m)$ is. This
symmetry, proved directly, is the seed of **detailed balance** — the
principle that emission and absorption of light are mirror processes, the
foundation on which Einstein built the theory of stimulated emission and,
eventually, the laser.

And the rules do permit the most famous transition of all: the
**Lyman-$\alpha$** line, $2p \to 1s$, in which the electron falls from
$\ell = 1$ to $\ell = 0$. It satisfies $\Delta\ell = -1$ and $\Delta m =
0$, so it is allowed. Lyman-$\alpha$ is the brightest ultraviolet line of
hydrogen, a workhorse of astronomy used to map hydrogen gas across the
cosmos. Its allowedness is, in the end, a one-line verification.

## The Pattern Beneath the Pattern

Step back and a single melody runs through all three movements. **Confine
a wave and it quantizes.** The radial confinement of the electron by the
proton's pull produces the energy ladder $-1/n^2$. The angular
confinement — the demand that the wave close up around the axis — produces
the integer angular momenta $m$. And the geometry of three-dimensional
space, through the algebra of angular momentum, produces both the $n^2$
degeneracy and the $\Delta\ell = \pm 1$ selection rule.

What is remarkable is how much of this is, at bottom, *arithmetic*. The
sum of odd numbers is a square. The negation of a null sequence is an
increasing one with a single accumulation point. The difference of two
reciprocal squares is positive. An integer is forced by periodicity.
Parity flips when a difference is odd. These are facts a curious child
could verify with pebbles and patience — and they are, simultaneously, the
load-bearing structure of the simplest atom in the universe.

The spectrum of hydrogen was the first great triumph of quantum theory,
the puzzle whose solution announced that the world is built from discrete,
countable possibilities rather than a smooth continuum of options. More
than a century later, every rung of that ladder, every state on every
rung, and every allowed leap between them can be derived with the full
certainty of mathematical proof. The music of the atom, it turns out, is
written in the oldest and most reliable language we have.
