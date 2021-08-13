/** Models a return type with baked in failure support. */
class TFC_Failable<ReturnType> {
  /** The value returnned from the function. */
  ReturnType _returnValue;
  
  /** The value returnned from the function. */
  ReturnType get returnValue {
    return _returnValue;
  }


  /** An object containing the details of the error. */
  Object? _errorObject;
  
  /** An object containing the details of the error. */
  Object? get errorObject {
    return _errorObject;
  }


  /** Whether or not the function succeeded. */
  bool get succeeded {
    return !failed;
  }

  /** Whether or not the function failed. */
  bool get failed {
    return errorObject != null;
  }


  /** Creates a successful return object. */
  TFC_Failable.succeeded({
    required ReturnType returnValue,
  })
    : this._returnValue = returnValue,
      this._errorObject = null;
      
  /** Creates a failed return object. */
  TFC_Failable.failed({
    required ReturnType returnValue,
    required Object errorObject,
  })
    : this._returnValue = returnValue,
      this._errorObject = errorObject;
}