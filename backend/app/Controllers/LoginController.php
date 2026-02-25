<?php

namespace App\Controllers;

use CodeIgniter\API\ResponseTrait;
use CodeIgniter\Controller;

class LoginController extends Controller
{
    use ResponseTrait;

    public function index()
    {
        // Backend "health" endpoint (or serve SPA from frontend separately)
        return $this->response->setJSON([
            'ok' => true,
            'message' => 'CI4 backend is running.',
        ]);
    }

    public function login()
    {
        $rules = [
            'nickname' => 'required|min_length[3]|max_length[64]',
            'password' => 'required|min_length[6]|max_length[128]',
        ];

        if (! $this->validate($rules)) {
            return $this->respond([
                'ok' => false,
                'message' => 'Hibás űrlap kitöltés.',
                'errors' => $this->validator->getErrors(),
            ], 422);
        }

        $nickname = (string) $this->request->getPost('nickname');
        $password = (string) $this->request->getPost('password');

        $db = db_connect();
        $user = $db->table('users')
            ->select('id, nickname, password_hash, is_active')
            ->where('nickname', $nickname)
            ->get()->getRowArray();

        if (! $user || (int)$user['is_active'] !== 1) {
            return $this->respond([
                'ok' => false,
                'message' => 'Hibás felhasználónév vagy jelszó.',
            ], 401);
        }

        if (! password_verify($password, $user['password_hash'])) {
            return $this->respond([
                'ok' => false,
                'message' => 'Hibás felhasználónév vagy jelszó.',
            ], 401);
        }

        session()->set([
            'user_id' => (int) $user['id'],
            'nickname' => $user['nickname'],
            'logged_in' => true,
        ]);

        return $this->respond([
            'ok' => true,
            'message' => 'Sikeres bejelentkezés!',
        ]);
    }

    public function logout()
    {
        session()->destroy();
        return $this->respond(['ok' => true, 'message' => 'Kijelentkezve.']);
    }

    public function createMenuItem()
    {
        // protected by auth filter in routes
        $rules = [
            'title' => 'required|min_length[2]|max_length[128]',
            'url' => 'permit_empty|max_length[255]',
            'parent_id' => 'permit_empty|is_natural_no_zero',
            'sort_order' => 'permit_empty|integer',
            'is_active' => 'permit_empty|in_list[0,1]',
        ];

        if (! $this->validate($rules)) {
            return $this->respond([
                'ok' => false,
                'message' => 'Hibás menü űrlap.',
                'errors' => $this->validator->getErrors(),
            ], 422);
        }

        $data = [
            'title' => (string) $this->request->getPost('title'),
            'url' => $this->request->getPost('url') !== '' ? (string) $this->request->getPost('url') : null,
            'parent_id' => $this->request->getPost('parent_id') ? (int) $this->request->getPost('parent_id') : null,
            'sort_order' => $this->request->getPost('sort_order') !== null ? (int) $this->request->getPost('sort_order') : 0,
            'is_active' => $this->request->getPost('is_active') !== null ? (int) $this->request->getPost('is_active') : 1,
        ];

        $db = db_connect();

        if ($data['parent_id'] !== null) {
            $exists = $db->table('menus')->select('id')->where('id', $data['parent_id'])->get()->getRowArray();
            if (! $exists) {
                return $this->respond([
                    'ok' => false,
                    'message' => 'A megadott parent_id nem létezik.',
                ], 422);
            }
        }

        $db->table('menus')->insert($data);

        return $this->respond([
            'ok' => true,
            'message' => 'Menüpont létrehozva.',
            'id' => (int) $db->insertID(),
        ], 201);
    }

    public function menuTree()
    {
        $db = db_connect();
        $rows = $db->table('menus')
            ->select('id, title, url, parent_id, sort_order, is_active')
            ->where('is_active', 1)
            ->orderBy('parent_id', 'ASC')
            ->orderBy('sort_order', 'ASC')
            ->orderBy('id', 'ASC')
            ->get()->getResultArray();

        $byParent = [];
        foreach ($rows as $r) {
            $pid = $r['parent_id'] ?? 0;
            if (! isset($byParent[$pid])) $byParent[$pid] = [];
            $byParent[$pid][] = $r;
        }

        $build = function($parentId) use (&$build, &$byParent) {
            $items = $byParent[$parentId] ?? [];
            $out = [];
            foreach ($items as $it) {
                $id = (int) $it['id'];
                $out[] = [
                    'id' => $id,
                    'title' => $it['title'],
                    'url' => $it['url'],
                    'children' => $build($id),
                ];
            }
            return $out;
        };

        return $this->respond([
            'ok' => true,
            'menu' => $build(0),
        ]);
    }
    
    public function me()
    {
        if (! session()->get('logged_in')) {
            return $this->failUnauthorized('Nincs bejelentkezve.');
        }

        return $this->respond([
            'ok' => true,
            'user' => [
                'id' => (int) session()->get('user_id'),
                'nickname' => (string) session()->get('nickname'),
            ],
        ]);
    }

    public function csrf()
    {
        // CI4 beépített helper-ek:
        // csrf_hash() = aktuális token érték
        return $this->respond([
            'ok' => true,
            'token' => csrf_hash(),
        ]);
    }    
}
