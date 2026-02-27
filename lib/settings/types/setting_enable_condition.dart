import 'package:clock_app/settings/types/setting.dart';
import 'package:clock_app/settings/types/setting_group.dart';
import 'package:clock_app/settings/types/setting_item.dart';

// Allows us to check conditions for enabling settings
abstract class EnableCondition {
  void setupEnableSettings(SettingGroup group, SettingItem item);
  void setupChangesEnableCondition(SettingGroup group, SettingItem item);
  ConditionEvaluator getEvaluator(SettingGroup group);
}

class GeneralCondition extends EnableCondition {
  bool Function() condition;

  GeneralCondition(this.condition);

  @override
  ConditionEvaluator getEvaluator(SettingGroup group) {
    return GeneralConditionEvaluator(condition);
  }

  @override
  void setupEnableSettings(SettingGroup group, SettingItem item) {
    item.enableSettings.add(getEvaluator(group));
  }

  @override
  void setupChangesEnableCondition(SettingGroup group, SettingItem item) {}
}

class ValueCondition extends EnableCondition {
  List<String> settingPath;
  bool Function(dynamic settingValue) condition;

  ValueCondition(this.settingPath, this.condition);

  @override
  ConditionEvaluator getEvaluator(SettingGroup group) {
    Setting setting = group.getSettingFromPath(settingPath);
    return ValueConditionEvaluator(setting, condition);
  }

  @override
  void setupEnableSettings(SettingGroup group, SettingItem item) {
    item.enableSettings.add(getEvaluator(group));
    // print(
    //     "${item.name} is enabled by ${setting.name} = ${enableCondition.value}");
  }

  @override
  void setupChangesEnableCondition(SettingGroup group, SettingItem item) {
    Setting setting = group.getSettingFromPath(settingPath);
    setting.changesEnableCondition = true;
  }
}

class CompoundCondition extends EnableCondition {
  EnableCondition parameter1;
  EnableCondition parameter2;
  bool Function(bool parameter1Result, bool parameter2Result) condition;
  CompoundCondition(this.parameter1, this.parameter2, this.condition);

  @override
  ConditionEvaluator getEvaluator(SettingGroup group) {
    return CompoundConditionEvaluator(parameter1.getEvaluator(group),
        parameter2.getEvaluator(group), condition);
  }

  @override
  void setupEnableSettings(SettingGroup group, SettingItem item) {
    item.enableSettings.add(getEvaluator(group));
    // print(
    //     "${item.name} is enabled by ${setting.name} = ${enableCondition.value}");
  }

  @override
  void setupChangesEnableCondition(SettingGroup group, SettingItem item) {
    parameter1.setupChangesEnableCondition(group, item);
    parameter2.setupChangesEnableCondition(group, item);
  }
}

abstract class ConditionEvaluator {
  bool evaluate();
}

class ValueConditionEvaluator extends ConditionEvaluator {
  Setting setting;
  bool Function(dynamic settingValue) condition;

  ValueConditionEvaluator(this.setting, this.condition);

  @override
  bool evaluate() {
    return condition(setting.value);
  }
}

class GeneralConditionEvaluator extends ConditionEvaluator {
  bool Function() condition;
  GeneralConditionEvaluator(this.condition);

  @override
  bool evaluate() {
    return condition();
  }
}

class CompoundConditionEvaluator extends ConditionEvaluator {
  ConditionEvaluator condition1;
  ConditionEvaluator condition2;
  bool Function(bool parameter1Result, bool parameter2Result) condition;
  CompoundConditionEvaluator(this.condition1, this.condition2, this.condition);

  @override
  bool evaluate() {
    return condition(condition1.evaluate(), condition2.evaluate());
  }
}
