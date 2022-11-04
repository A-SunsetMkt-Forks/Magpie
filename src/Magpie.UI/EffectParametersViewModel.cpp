#include "pch.h"
#include "EffectParametersViewModel.h"
#if __has_include("ScalingModeBoolParameter.g.cpp")
#include "ScalingModeBoolParameter.g.cpp"
#endif
#if __has_include("ScalingModeFloatParameter.g.cpp")
#include "ScalingModeFloatParameter.g.cpp"
#endif
#if __has_include("EffectParametersViewModel.g.cpp")
#include "EffectParametersViewModel.g.cpp"
#endif
#include <Magpie.Core.h>
#include "StrUtils.h"
#include "AppSettings.h"
#include "ScalingModesService.h"


using namespace Magpie::Core;


namespace winrt::Magpie::UI::implementation {

EffectParametersViewModel::EffectParametersViewModel(uint32_t scalingModeIdx, uint32_t effectIdx)
	: _scalingModeIdx(scalingModeIdx), _effectIdx(effectIdx)
{
	std::wstring_view effectName;
	if (_IsDefaultDownscalingEffect()) {
		effectName = AppSettings::Get().DownscalingEffect().name;
		if (effectName.empty()) {
			return;
		}
	} else {
		ScalingMode& scalingMode = ScalingModesService::Get().GetScalingMode(_scalingModeIdx);
		effectName = scalingMode.effects[_effectIdx].name;
	}
	_effectInfo = EffectsService::Get().GetEffect(effectName);

	phmap::flat_hash_map<std::wstring, float>& params = _Data();

	std::vector<IInspectable> boolParams;
	std::vector<IInspectable> floatParams;
	for (uint32_t i = 0, size = (uint32_t)_effectInfo->params.size(); i < size; ++i) {
		const EffectParameterDesc& param = _effectInfo->params[i];

		std::optional<float> paramValue;
		{
			auto it = params.find(StrUtils::UTF8ToUTF16(param.name));
			if (it != params.end()) {
				paramValue = it->second;
			}
		}

		if (param.constant.index() == 0) {
			const EffectConstant<float>& constant = std::get<0>(param.constant);
			Magpie::UI::ScalingModeFloatParameter floatParamItem(
				i,
				StrUtils::UTF8ToUTF16(param.label.empty() ? param.name : param.label),
				paramValue.has_value() ? *paramValue : constant.defaultValue,
				constant.minValue,
				constant.maxValue,
				constant.step
			);
			floatParamItem.PropertyChanged({ this, &EffectParametersViewModel::_ScalingModeFloatParameter_PropertyChanged });
			floatParams.push_back(floatParamItem);
		} else {
			const EffectConstant<int>& constant = std::get<1>(param.constant);
			if (constant.minValue == 0 && constant.maxValue == 1 && constant.step == 1) {
				Magpie::UI::ScalingModeBoolParameter boolParamItem(
					i,
					StrUtils::UTF8ToUTF16(param.label.empty() ? param.name : param.label),
					paramValue.has_value() ? std::abs(*paramValue) > 1e-6 : (bool)constant.defaultValue
				);
				boolParamItem.PropertyChanged({ this, &EffectParametersViewModel::_ScalingModeBoolParameter_PropertyChanged });
				boolParams.push_back(boolParamItem);
			} else {
				Magpie::UI::ScalingModeFloatParameter floatParamItem(
					i,
					StrUtils::UTF8ToUTF16(param.label.empty() ? param.name : param.label),
					paramValue.has_value() ? *paramValue : (float)constant.defaultValue,
					(float)constant.minValue,
					(float)constant.maxValue,
					(float)constant.step
				);
				floatParamItem.PropertyChanged({ this, &EffectParametersViewModel::_ScalingModeFloatParameter_PropertyChanged });
				floatParams.push_back(floatParamItem);
			}
		}
	}
	if (!boolParams.empty()) {
		_boolParams = single_threaded_vector(std::move(boolParams));
	}
	if (!floatParams.empty()) {
		_floatParams = single_threaded_vector(std::move(floatParams));
	}
}

void EffectParametersViewModel::_ScalingModeBoolParameter_PropertyChanged(
	IInspectable const& sender,
	PropertyChangedEventArgs const& args
) {
	if (args.PropertyName() != L"Value") {
		return;
	}

	ScalingModeBoolParameter* boolParamImpl =
		get_self<ScalingModeBoolParameter>(sender.as<default_interface<ScalingModeBoolParameter>>());
	const std::string& effectName = _effectInfo->params[boolParamImpl->Index()].name;
	_Data()[StrUtils::UTF8ToUTF16(effectName)] = (float)boolParamImpl->Value();
}

void EffectParametersViewModel::_ScalingModeFloatParameter_PropertyChanged(
	IInspectable const& sender,
	PropertyChangedEventArgs const& args
) {
	if (args.PropertyName() != L"Value") {
		return;
	}

	ScalingModeFloatParameter* floatParamImpl =
		get_self<ScalingModeFloatParameter>(sender.as<default_interface<ScalingModeFloatParameter>>());
	const std::string& effectName = _effectInfo->params[floatParamImpl->Index()].name;
	_Data()[StrUtils::UTF8ToUTF16(effectName)] = (float)floatParamImpl->Value();
}

phmap::flat_hash_map<std::wstring, float>& EffectParametersViewModel::_Data() {
	if (_IsDefaultDownscalingEffect()) {
		return AppSettings::Get().DownscalingEffect().parameters;
	}

	ScalingMode& scalingMode = ScalingModesService::Get().GetScalingMode(_scalingModeIdx);
	return scalingMode.effects[_effectIdx].parameters;
}

}
