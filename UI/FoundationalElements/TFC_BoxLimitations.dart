abstract class TFC_BoxLimitation {
  const TFC_BoxLimitation();
}

class TFC_NoLimitations extends TFC_BoxLimitation {
  const TFC_NoLimitations();
}

class TFC_MustBeFixedSize extends TFC_NoLimitations {
  const TFC_MustBeFixedSize();
}