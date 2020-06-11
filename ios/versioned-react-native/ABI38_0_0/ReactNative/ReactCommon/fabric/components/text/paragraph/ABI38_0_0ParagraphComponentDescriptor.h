/*
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include "ABI38_0_0ParagraphShadowNode.h"

#include <ABI38_0_0React/config/ABI38_0_0ReactNativeConfig.h>
#include <ABI38_0_0React/core/ConcreteComponentDescriptor.h>
#include <ABI38_0_0React/textlayoutmanager/TextLayoutManager.h>
#include <ABI38_0_0React/utils/ContextContainer.h>

namespace ABI38_0_0facebook {
namespace ABI38_0_0React {

/*
 * Descriptor for <Paragraph> component.
 */
class ParagraphComponentDescriptor final
    : public ConcreteComponentDescriptor<ParagraphShadowNode> {
 public:
  ParagraphComponentDescriptor(
      EventDispatcher::Weak eventDispatcher,
      ContextContainer::Shared const &contextContainer,
      ComponentDescriptor::Flavor const &flavor = {})
      : ConcreteComponentDescriptor<ParagraphShadowNode>(
            eventDispatcher,
            contextContainer,
            flavor) {
    // Every single `ParagraphShadowNode` will have a reference to
    // a shared `TextLayoutManager`.
    textLayoutManager_ = std::make_shared<TextLayoutManager>(contextContainer);
  }

 protected:
  void adopt(UnsharedShadowNode shadowNode) const override {
    ConcreteComponentDescriptor::adopt(shadowNode);

    assert(std::dynamic_pointer_cast<ParagraphShadowNode>(shadowNode));
    auto paragraphShadowNode =
        std::static_pointer_cast<ParagraphShadowNode>(shadowNode);

    // `ParagraphShadowNode` uses `TextLayoutManager` to measure text content
    // and communicate text rendering metrics to mounting layer.
    paragraphShadowNode->setTextLayoutManager(textLayoutManager_);

    paragraphShadowNode->dirtyLayout();

    // All `ParagraphShadowNode`s must have leaf Yoga nodes with properly
    // setup measure function.
    paragraphShadowNode->enableMeasurement();
  }

 private:
  SharedTextLayoutManager textLayoutManager_;
};

} // namespace ABI38_0_0React
} // namespace ABI38_0_0facebook
