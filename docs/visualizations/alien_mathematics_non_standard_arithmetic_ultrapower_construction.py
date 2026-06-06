class NonstdNatElement:
    def __init__(self, seq): self.seq = seq
    @staticmethod
    def standard(n): return NonstdNatElement(lambda _: n)
    @staticmethod
    def omega(): return NonstdNatElement(lambda i: i)
    def add(self, other): return NonstdNatElement(lambda i: self.seq(i) + other.seq(i))
    def mul(self, other): return NonstdNatElement(lambda i: self.seq(i) * other.seq(i))