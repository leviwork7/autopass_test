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

    describe "《 1-1 》單滿 X 元折 Z %" do
      context "單滿 6000 元折 10 %" do
        let!(:promotion) {
          promotion = Promotion.create!(title: "單滿 6000 元折 10 %")
          PromotionRule::Order.create!(
            minimum_amount: 6000,
            promotion: promotion)
          PromotionAction::OrderDiscount.create!(
            calc_type: :percentage, calc_value: 0.1,
            promotion: promotion)
          promotion
        }

        context "商品總額 $ 6000" do
          it do
            order.order_items.create!(quantity: 2, product: create(:product, price: 1000))
            order.order_items.create!(quantity: 2, product: create(:product, price: 2000))

            expect(subject).to eq(6000 - (6000 * 0.1))
          end
        end

        context "來回變更條件" do
          it do
            # 單滿 6000 元
            order.order_items.create!(quantity: 6, product: create(:product, price: 1000))
            expect(order.calc_total).to eq(5400)
            expect(order.order_promotions.count).to eq(1)

            # 改為 5000 元
            order.order_items.first.update(quantity: 5)
            expect(order.calc_total).to eq(5000)
            expect(order.order_promotions.count).to eq(0)

            # 改為 6000 元
            order.order_items.first.update(quantity: 6)
            expect(order.calc_total).to eq(5400)
            expect(order.order_promotions.count).to eq(1)
          end
        end

        context "刪除優惠項目" do
          it do
            order.order_items.create!(quantity: 1, product: create(:product, price: 6000))
            expect(order.calc_total).to eq(5400)

            promotion.delete
            expect(order.calc_total).to eq(6000)
          end
        end

        context "《 加分題 》單滿 X 元折 Z % 折扣每⼈只 總共優惠 N 元" do
          context "每⼈只總共優惠 1000 元，先前使用 $600 折扣" do
            before do
              # 增加優惠額度：$1000
              promotion.actions.first.update(quota_amount: 1000)

              # 先前已使用 600 折扣
              previous_order = create(:order, user: user)
              previous_order.order_items.create!(quantity: 1, product: create(:product, price: 6000))
              expect(previous_order.calc_total).to eq(5400)
            end

            it do
              order.order_items.create!(quantity: 1, product: create(:product, price: 6000))
              expect(subject).to eq(6000 - (1000 - 600))
            end
          end
        end
      end

      context "《 1-4 》單滿 X 元折 Y 元 此折扣在全站總共只 套⽤ N 次" do
        context "單滿 2000 元折 200 元 此折扣在全站總共只 套⽤ 2 次" do
          let!(:promotion) {
            promotion = Promotion.create!(title: "單滿 2000 元折 200")
            PromotionRule::Order.create!(
              minimum_amount: 2000,
              promotion: promotion)
            PromotionRule::AllUser.create!(
              maximum_quantity: 2,
              promotion: promotion)
            PromotionAction::OrderDiscount.create!(
              calc_type: :fixed, calc_value: 200,
              promotion: promotion)
            promotion
          }

          before do
            # 某 A 套用 1 次
            order_A = create(:order, user: create(:user))
            order_A.order_items.create!(quantity: 1, product: create(:product, price: 2000))
            expect(order_A.calc_total).to eq(2000 - 200)

            # 某 B 套用 1 次
            order_B = create(:order, user: create(:user))
            order_B.order_items.create!(quantity: 1, product: create(:product, price: 2000))
            expect(order_B.calc_total).to eq(2000 - 200)

            expect(Order.count).to eq(2)
            expect(OrderPromotion.count).to eq(2)
          end

          it do
            order.order_items.create!(quantity: 1, product: create(:product, price: 2000))
            expect(subject).to eq(2000)
          end
        end
      end
    end

    describe "《 1-2 》特定商品滿 X 件折 Y 元" do
      context "特定商品滿 5 件，訂單金額折 1000 元" do
        let!(:promo_product) { create(:product, price: 1000) }
        let!(:promotion) {
          promotion = Promotion.create!(title: "特定商品滿 5 件折 1000 元")
          PromotionRule::OrderItem.create!(
            minimum_quantity: 5,
            promotion: promotion, product: promo_product)
          PromotionAction::OrderDiscount.create!(
            calc_type: :fixed, calc_value: 1000,
            promotion: promotion)
          promotion
        }

        context "商品 $ 1000, 購買 5 件" do
          it do
            order.order_items.create!(quantity: 5, product: promo_product)
            expect(subject).to eq((1000 * 5) - 1000)
          end
        end

        context "來回變更條件" do
          it do
            # 滿 5 件
            order.order_items.create!(quantity: 5, product: promo_product)
            expect(order.calc_total).to eq(4000)
            expect(order.order_promotions.count).to eq(1)

            # 更改為 3 件
            order.order_items.first.update(quantity: 3)
            expect(order.calc_total).to eq(3000)
            expect(order.order_promotions.count).to eq(0)

            # 更改為 5 件
            order.order_items.first.update(quantity: 5)
            expect(order.calc_total).to eq(4000)
            expect(order.order_promotions.count).to eq(1)
          end
        end
      end

      context "特定商品滿 5 件，每件售價 8 折" do
        let!(:promo_product) { create(:product, price: 1000) }
        let!(:promotion) {
          promotion = Promotion.create!(title: "特定商品滿 5 件，每件售價折 20%")
          PromotionRule::OrderItem.create(
            minimum_quantity: 5,
            promotion: promotion, product: promo_product)
          PromotionAction::OrderItemDiscount.create!(
            calc_type: :percentage, calc_value: 0.2,
            promotion: promotion, product: promo_product)
          promotion
        }

        context "商品 $ 1000, 購買 5 件" do
          it do
            order.order_items.create!(quantity: 5, product: promo_product)
            expect(subject).to eq((1000 * 0.8) * 5)
          end
        end
      end
    end

    describe "《 1-3 》單滿 X 元 送特定商品" do
      context "滿 2000 元 送特定商品" do
        let!(:promotion) {
          promotion = Promotion.create!(title: "滿 2000 元 送特定商品")
          PromotionRule::Order.create!(
            minimum_amount: 2000,
            promotion: promotion)
          PromotionAction::FreeOrderItem.create!(
            product: target_free_product,
            promotion: promotion,)
          promotion
        }
        let!(:target_free_product) { create(:product, name: "滿額贈商品", price: 300) }

        before do
          order.order_items.create!(quantity: 1, product: create(:product, price: 2000))
        end

        it { expect(subject).to eq(2000) }
        it { expect { subject }.to change { order.order_items.free.count }.by(1) }
        it { expect { subject }.to change { order.order_items.free.first&.product }.to(target_free_product) }

        context "來回變更條件" do
          it do
            # 總金額 2000
            expect(order.calc_total).to eq(2000)
            expect(order.order_items.normal.count).to eq(1)
            expect(order.order_items.free.count).to eq(1)

            # 更改總金額為 1000
            order.order_items.first.update(price: 1000)
            expect(order.calc_total).to eq(1000)
            expect(order.order_items.normal.count).to eq(1)
            expect(order.order_items.free.count).to eq(0)

            # 更改總金額為 2000
            order.order_items.first.update(price: 2000)
            expect(order.calc_total).to eq(2000)
            expect(order.order_items.normal.count).to eq(1)
            expect(order.order_items.free.count).to eq(1)
          end
        end
      end
    end

    describe "《 加分題 》單滿 X 元折 Y 元 此折扣在全站每個⽉折扣上限為 N 元" do
      context "單滿 5000 元折 500 元 此折扣在全站每個⽉折扣上限為 1000 元" do
        let!(:promotion) {
          promotion = Promotion.create!(title: "單滿 5000 元折 500 元")
          PromotionRule::Order.create!(
            minimum_amount: 5000,
            promotion: promotion)
          PromotionRule::AllUser.create!(
            period: "monthly", maximum_amount: 1000,
            promotion: promotion)
          PromotionAction::OrderDiscount.create!(
            calc_type: :fixed, calc_value: 500,
            promotion: promotion)
          promotion
        }
        let(:end_of_month) { Time.now.end_of_month }

        before do
          Timecop.freeze(end_of_month) do
            # 某 A 折 500
            order_A = create(:order, user: create(:user))
            order_A.order_items.create!(quantity: 1, product: create(:product, price: 5000))
            expect(order_A.calc_total).to eq(5000 - 500)

            # 某 B 折 500
            order_B = create(:order, user: create(:user))
            order_B.order_items.create!(quantity: 1, product: create(:product, price: 5000))
            expect(order_B.calc_total).to eq(5000 - 500)
          end
        end

        it do
          # 本月優惠已達上限
          Timecop.freeze(end_of_month) do
            order.order_items.create!(quantity: 1, product: create(:product, price: 5000))
            expect(order.calc_total).to eq(5000)
            expect(order.order_promotions.count).to eq(0)
          end

          # 到了隔月，優惠可以再次套用
          Timecop.freeze(end_of_month + 1.days) do
            expect(order.calc_total).to eq(5000 - 500)
            expect(order.order_promotions.count).to eq(1)
          end
        end
      end
    end
  end
end
