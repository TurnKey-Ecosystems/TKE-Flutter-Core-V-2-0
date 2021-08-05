import '../../Utilities/TFC_BasicValueWrapper.dart';
import '../TFC_AllItemsManager.dart';
import '../TFC_SyncLevel.dart';
import 'TFC_Attribute.dart';
import 'TFC_InstanceOfAttribute.dart';


// Provides a control pannel for an instance of a property type attribute
abstract class _TFC_AttributeProperty<PropertyType> extends TFC_Attribute<TFC_InstanceOfAttributeProperty<dynamic>> implements TFC_BasicValueWrapper<PropertyType> {
  // Expose the value of the attribute
  PropertyType get value {
    return attributeInstance.value;
  }
  PropertyType getValue() {
    return value;
  }


  // Changes to the attribute made through this class are considered local changes
  void set value(PropertyType newValue) {
    attributeInstance.setValue(
      newValue: newValue,
      changeSource: TFC_ChangeSource.DEVICE,
    );
  }
  void setValue(PropertyType newValue) {
    value = newValue;
  }


  // This is the value this attribute should have when it's item is first created.
  final PropertyType valueOnCreateNew;


  // Creates a new property attribute
  _TFC_AttributeProperty({
    required String attributeKey,
    required TFC_SyncLevel syncLevel,
    required this.valueOnCreateNew,
  }) : super(
    attributeKey: attributeKey,
    syncLevel: syncLevel,
  );
}



// Provides a control pannel for an instance of a boolean attribute
class TFC_AttributeBool extends _TFC_AttributeProperty<bool> {
  TFC_AttributeBool({
    required String attributeKey,
    required TFC_SyncLevel syncLevel,
    required bool valueOnCreateNew,
  }) : super(
    attributeKey: attributeKey,
    syncLevel: syncLevel,
    valueOnCreateNew: valueOnCreateNew
  );
}



// Provides a control pannel for an instance of an int attribute
class TFC_AttributeInt extends _TFC_AttributeProperty<int> {
  TFC_AttributeInt({
    required String attributeKey,
    required TFC_SyncLevel syncLevel,
    required int valueOnCreateNew,
  }) : super(
    attributeKey: attributeKey,
    syncLevel: syncLevel,
    valueOnCreateNew: valueOnCreateNew
  );
}



// Provides a control pannel for an instance of a double attribute
class TFC_AttributeDouble extends _TFC_AttributeProperty<double> {
  TFC_AttributeDouble({
    required String attributeKey,
    required TFC_SyncLevel syncLevel,
    required double valueOnCreateNew,
  }) : super(
    attributeKey: attributeKey,
    syncLevel: syncLevel,
    valueOnCreateNew: valueOnCreateNew
  );
}



// Provides a control pannel for an instance of a String attribute
class TFC_AttributeString extends _TFC_AttributeProperty<String> {
  TFC_AttributeString({
    required String attributeKey,
    required TFC_SyncLevel syncLevel,
    required String valueOnCreateNew,
  }) : super(
    attributeKey: attributeKey,
    syncLevel: syncLevel,
    valueOnCreateNew: valueOnCreateNew
  );
}



// Provides a control pannel for an instance of a session exlusive object attribute
class TFC_AttributeSessionObject<ObjectType> extends _TFC_AttributeProperty<ObjectType> {
  TFC_AttributeSessionObject({
    required String attributeKey,
    required ObjectType valueOnCreateNew,
  }) : super(
    attributeKey: attributeKey,
    syncLevel: TFC_SyncLevel.SESSION,
    valueOnCreateNew: valueOnCreateNew
  );
}