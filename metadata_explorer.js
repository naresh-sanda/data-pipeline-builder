
    // --- Metadata Explorer Logic ---
    function showMetadataExplorer() {
      const modal = new bootstrap.Modal(document.getElementById('metadataExplorerModal'));
      modal.show();
      renderMetadataTree();
    }

    function renderMetadataTree() {
      const treeContainer = document.getElementById('metaExplorerTree');
      // Mock Data Structure
      const metadata = {
        name: 'main',
        type: 'catalog',
        children: [
          {
            name: 'dw',
            type: 'schema',
            children: [
              { name: 'customers', type: 'table', rowCount: 15420, size: '2.5 GB' },
              { name: 'sales_orders', type: 'table', rowCount: 450012, size: '18.2 GB' },
              { name: 'products', type: 'table', rowCount: 3200, size: '150 MB' },
              { name: 'dim_date', type: 'table', rowCount: 7300, size: '2 MB' }
            ]
          },
          {
            name: 'dm',
            type: 'schema',
            children: [
              { name: 'report_monthly_sales', type: 'table', rowCount: 48, size: '100 KB' },
              { name: 'report_top_customers', type: 'table', rowCount: 100, size: '50 KB' }
            ]
          },
          {
             name: 'staging',
             type: 'schema',
             children: [
                { name: 'raw_events', type: 'table', rowCount: 0, size: '0 GB' }
             ]
          }
        ]
      };

      let html = `<ul class="list-unstyled ms-2">`;
      // Catalog Node
      html += `
        <li>
          <div class="d-flex align-items-center p-1 rounded" style="cursor: pointer;" onclick="toggleTree(this)">
            <i class="fas fa-caret-down text-muted me-2"></i>
            <i class="fas fa-database text-warning me-2"></i>
            <strong>${metadata.name}</strong>
          </div>
          <ul class="list-unstyled ms-4 show">
      `;

      metadata.children.forEach(schema => {
        html += `
          <li>
            <div class="d-flex align-items-center p-1 rounded" style="cursor: pointer;" onclick="toggleTree(this)">
              <i class="fas fa-caret-down text-muted me-2"></i>
              <i class="fas fa-folder text-primary me-2"></i>
              ${schema.name}
            </div>
            <ul class="list-unstyled ms-4 show">
        `;
        schema.children.forEach(table => {
          html += `
            <li>
              <div class="d-flex align-items-center p-1 rounded tree-item" style="cursor: pointer;" 
                   onclick="showMetaDetails('table', '${table.name}', {rowCount: ${table.rowCount}, size: '${table.size}'}, this)">
                <i class="fas fa-table text-success me-2 ms-2"></i>
                <span class="text-dark">${table.name}</span>
              </div>
            </li>
          `;
        });
        html += `</ul></li>`;
      });

      html += `</ul></li></ul>`;
      treeContainer.innerHTML = html;
    }

    function toggleTree(element) {
      const childrenContainer = element.nextElementSibling;
      const icon = element.querySelector('.fa-caret-down, .fa-caret-right');
      if (childrenContainer) {
        childrenContainer.classList.toggle('d-none');
        if (icon) {
            icon.classList.toggle('fa-caret-down');
            icon.classList.toggle('fa-caret-right');
        }
      }
    }

    function showMetaDetails(type, name, data, element) {
      // Highlight selection
      document.querySelectorAll('.tree-item').forEach(el => el.classList.remove('bg-info', 'text-white'));
      if(element) {
          element.classList.add('bg-info', 'text-white');
          element.querySelector('span').classList.remove('text-dark');
          element.querySelector('span').classList.add('text-white');
          element.querySelector('i').classList.remove('text-success');
          element.querySelector('i').classList.add('text-white');
      }


      const pane = document.getElementById('metaDetailPane');
      if (type === 'table') {
        const columns = [
             {name: 'id', type: 'INT', key:'PK'},
             {name: 'created_at', type: 'TIMESTAMP', key:''},
             {name: 'updated_at', type: 'TIMESTAMP', key:''},
             {name: 'status', type: 'VARCHAR(20)', key:''}
        ];
        
        // Add random mock columns based on name
        if(name.includes('customer')) columns.push({name: 'email', type: 'VARCHAR(100)', key:''}, {name: 'full_name', type: 'VARCHAR(100)', key:''});
        if(name.includes('sales')) columns.push({name: 'amount', type: 'DECIMAL(10,2)', key:''}, {name: 'customer_id', type: 'INT', key:'FK'});

        let colsHtml = columns.map(c => `
            <tr>
                <td>${c.key === 'PK' ? '<i class="fas fa-key text-warning" title="Primary Key"></i> ' : c.key === 'FK' ? '<i class="fas fa-key text-muted" title="Foreign Key"></i> ' : ''}<strong>${c.name}</strong></td>
                <td><code>${c.type}</code></td>
                <td><span class="badge bg-secondary">No</span></td>
            </tr>
        `).join('');

        pane.innerHTML = `
          <h4 class="mb-4"><i class="fas fa-table text-primary me-2"></i>${name}</h4>
          
          <div class="row mb-4">
             <div class="col-6">
                <div class="card p-3 border-0 bg-white shadow-sm">
                    <small class="text-muted text-uppercase">Row Count</small>
                    <div class="fs-4 fw-bold">${data.rowCount.toLocaleString()}</div>
                </div>
             </div>
             <div class="col-6">
                <div class="card p-3 border-0 bg-white shadow-sm">
                    <small class="text-muted text-uppercase">Size</small>
                    <div class="fs-4 fw-bold">${data.size}</div>
                </div>
             </div>
          </div>

          <h6 class="fw-bold border-bottom pb-2 mb-3">Columns Schema</h6>
          <table class="table table-hover">
            <thead class="table-light">
                <tr>
                    <th>Column Name</th>
                    <th>Data Type</th>
                    <th>Nullable</th>
                </tr>
            </thead>
            <tbody>${colsHtml}</tbody>
          </table>
        `;
      }
    }
