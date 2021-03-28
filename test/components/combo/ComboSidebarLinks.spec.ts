import { shallowMount } from "@vue/test-utils";
import ComboSidebarLinks from "@/components/combo/ComboSidebarLinks.vue";

describe("ComboSidebarLinks", () => {
  it("creates a copy combo button", () => {
    const CopyComboLinkButtonStub = { template: "<div></div>" };
    const wrapper = shallowMount(ComboSidebarLinks, {
      stubs: {
        CopyComboLinkButton: CopyComboLinkButtonStub,
      },
      propsData: {
        comboLink: "https://example.com/combo/3",
      },
    });

    expect(wrapper.findComponent(CopyComboLinkButtonStub).exists()).toBe(true);
  });

  it("creates buy this combo buttons", () => {
    const BuyComboButtonsStub = {
      template: "<div></div>",
      props: ["cards", "tcgplayerPrice", "cardkingdomPrice"],
    };
    const wrapper = shallowMount(ComboSidebarLinks, {
      stubs: {
        BuyComboButtons: BuyComboButtonsStub,
      },
      propsData: {
        comboLink: "https://example.com/combo/3",
        comboId: "fake-id",
        cards: ["card 1", "card 2"],
        tcgplayerPrice: "123.45",
        cardkingdomPrice: "67.89",
      },
    });

    expect(wrapper.findComponent(BuyComboButtonsStub).exists()).toBe(true);
    expect(wrapper.findComponent(BuyComboButtonsStub).props("cards")).toEqual([
      "card 1",
      "card 2",
    ]);
    expect(
      wrapper.findComponent(BuyComboButtonsStub).props("tcgplayerPrice")
    ).toBe("123.45");
    expect(
      wrapper.findComponent(BuyComboButtonsStub).props("cardkingdomPrice")
    ).toBe("67.89");
  });

  it("creates a 'Find Other Combos Using These Cards' button when there are related searches", () => {
    const SimiliarCombosButtonStub = { template: "<div></div>" };
    const wrapper = shallowMount(ComboSidebarLinks, {
      stubs: {
        SimiliarCombosButton: SimiliarCombosButtonStub,
      },
      propsData: {
        comboLink: "https://example.com/combo/3",
        comboId: "fake-id",
        cards: ["card 1", "card 2"],
      },
    });

    expect(wrapper.findComponent(SimiliarCombosButtonStub).exists()).toBe(true);
  });
});
