window.App.Inventory.url = => "/manage/#{App.InventoryPool.current.id}/inventory"

window.App.Inventory.findByInventoryCode = (inventory_code)=> $.get "/manage/#{App.InventoryPool.current.id}/inventory/#{inventory_code}"

window.App.Inventory.fetch = (params) => $.get App.Inventory.url() + ".json", params
