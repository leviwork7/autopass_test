require "rails_helper"

RSpec.describe Order, type: :model do
  let(:user) { create(:user) }
  let(:order) { create(:order, user: user) }

  describe "#calc_total" do
    subject { order.calc_total }

    describe "正確計算商品總額" do
      context "5 件 $ 1000 元商品" do
        before do
          order.order_items.create!(quantity: 1, product: create(:product, price: 1000))
          order.order_items.create!(quantity: 2, product: create(:product, price: 2000))

          expect(order.order_items.count).to eq(2)
        end

        it { expect(order.item_total).to eq(5000) }
        it { expect(subject).to eq(5000) }
      end
    end
  end
end
