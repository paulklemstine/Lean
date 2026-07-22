from dataclasses import dataclass

@dataclass(frozen=True)
class TaggedIndex:
    tag: int
    payload_index: int

def encode(tag: int, payload_index: int, tag_count: int) -> int:
    if tag_count < 1 or not 0 <= tag < tag_count or payload_index < 0:
        raise ValueError("invalid tagged index")
    return tag_count * payload_index + tag

def decode(code: int, tag_count: int) -> TaggedIndex:
    if code < 0 or tag_count < 1:
        raise ValueError("code must be nonnegative and tag_count positive")
    payload_index, tag = divmod(code, tag_count)
    return TaggedIndex(tag, payload_index)

if __name__ == "__main__":
    for r in range(1, 8):
        for n in range(20):
            for i in range(r):
                assert decode(encode(i, n, r), r) == TaggedIndex(i, n)
    print("All quotient-remainder round trips passed.")
