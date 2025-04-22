open Component_defs

type idx = One | Two
type tag += Portal of idx * (int * int) * portal
